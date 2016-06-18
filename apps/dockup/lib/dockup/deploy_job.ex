defmodule Dockup.DeployJob do
  require Logger

  def spawn_process({id, repository, branch, callback}) do
    spawn(fn -> perform(id, repository, branch, callback) end)
  end

  def perform(project_identifier, repository, branch, callback, project \\ Dockup.Project,
               config_generator \\ Dockup.ConfigGenerator) do
    #project_id = project.project_id(repository, branch)
    project_id = String.to_string(project_identifier)
    project.clone_repository(project_id, repository, branch)

    # Read config
    # if config can't be read, do the following
    urls = project.project_type(project_id)
    |> deploy(project_id, config_generator, project)

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

  def deploy(:static_site, project_id, config_generator, project) do
    Logger.info "Deploying static site #{project_id}"
    config_generator.generate(:static_site, project_id)
    project.start(project_id)
  end

  def deploy(_, app_id, _, _) do
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
end
