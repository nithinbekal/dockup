defmodule Dockup.DeployJob do
  require Logger

  def spawn_process({repository, branch, callback}) do
    spawn(fn -> perform(repository, branch, callback) end)
  end

  def perform(repository, branch, callback, project \\ Dockup.Project,
               nginx_config \\ Dockup.NginxConfig, container \\ Dockup.Container) do
    project_id = project.project_id(repository, branch)
    project.clone_repository(repository, branch)

    # Read config
    # if config can't be read, do the following
    project.auto_detect_project_type(project_id)
    |> deploy(project_id, nginx_config, container)

    urls = %{}
    success_callback(callback, repository, branch, urls)
  rescue
    e in DockupException ->
      Logger.error e.message
      error_callback(callback, repository, branch, e.message)
  end

  defp deploy(:static_site, project_id, nginx_config, container) do
    Logger.info "Deploying static site #{project_id}"
    nginx_config.write_config(:static_site, project_id)
    container.reload_nginx
  end

  defp deploy(_, app_id, _, _) do
    Logger.error "Don't know how to deploy #{app_id}"
  end

  # Callback handlers
  defp success_callback({callback_module, callback_args}, repository, branch, urls) do
    callback_module.deployment_success(repository, branch, urls, callback_args)
  end

  defp error_callback({callback_module, callback_args}, repository, branch, reason) do
    callback_module.deployment_failure(repository, branch, reason, callback_args)
  end
end
