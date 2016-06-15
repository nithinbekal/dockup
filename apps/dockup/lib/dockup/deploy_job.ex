defmodule Dockup.DeployJob do
  require Logger

  def spawn_process({id, repository, branch, callback}) do
    spawn(fn -> perform(id, repository, branch, callback) end)
  end

  def perform(project_id, repository, branch, callback, project \\ Dockup.Project,
               config_generator \\ Dockup.ConfigGenerator, container \\ Dockup.Container) do
    #project_id = project.project_id(repository, branch)
    project.clone_repository(project_id, repository, branch)

    # Read config
    # if config can't be read, do the following
    urls = project.project_type(project_id)
    |> deploy(project_id, config_generator, container)

    project.wait_till_up(urls)
    success_callback(callback, repository, branch, urls)
  rescue
    error in MatchError ->
      Logger.error (inspect error)
      error_callback(callback, repository, branch, (inspect error))
    e ->
      Logger.error e.message
      error_callback(callback, repository, branch, e.message)
  end

  defp deploy(:static_site, project_id, config_generator, container) do
    Logger.info "Deploying static site #{project_id}"
    Dockup.ConfigGenerator.generate(:static_site, project_id)
    Dockup.Container.start(project_id)
    url = ""
    container.reload_nginx
    url
  end

  defp deploy(_, app_id, _, _) do
    raise DockupException, "Don't know how to deploy #{app_id}"
  end

  # Callback handlers
  defp success_callback({callback_module, callback_args}, repository, branch, urls) do
    callback_module.deployment_success(repository, branch, urls, callback_args)
  rescue
    e ->
      Logger.error "An error occurred in the success callback: #{e.message}"
  end

  defp error_callback({callback_module, callback_args}, repository, branch, reason) do
    callback_module.deployment_failure(repository, branch, reason, callback_args)
  end

  defp localtime do
    {{year, month, day}, {hour, minute, second}} = :calendar.local_time
    "#{year}-#{month}-#{day} #{hour}:#{minute}:#{second}"
  end
end
