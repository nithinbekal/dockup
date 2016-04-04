defmodule Dockup.DeployJob do
  require Logger

  def spawn_process({repository, branch, callback}) do
    spawn(fn -> perform(repository, branch, callback) end)
  end

  defp perform(repository, branch, callback) do
    project_id = Dockup.Project.project_id(repository, branch)
    Dockup.Project.clone_repository(repository, branch)

    # Read config
    # if config can't be read, do the following
    urls = Dockup.Project.auto_detect_project_type(project_id)
            |> deploy project_id

    success_callback(callback, repository, branch, urls)
  rescue
    e in DockupException ->
      Logger.error e.message
      error_callback(callback, repository, branch, e.message)
  end

  defp deploy(:static_site, project_id) do
    # TODO
  end

  defp deploy(_, app_id) do
    Logger.error "Don't know how to deploy #{app_id}"
  end

  # Callback handlers
  defp success_callback({:webhook_callback, callback_url}, repository, branch, urls, webhook_callback \\ Dockup.Callbacks.Webhook) do
    webhook_callback.deployment_success(repository, branch, urls, callback_url)
  end

  defp error_callback({:webhook_callback, callback_url}, repository, branch, reason, webhook_callback \\ Dockup.Callbacks.Webhook) do
    webhook_callback.deployment_failure(repository, branch, reason, callback_url)
  end
end
