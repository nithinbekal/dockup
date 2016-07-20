defmodule Dockup.DeployJob do
  require Logger

  def spawn_process({id, repository, branch, callback}) do
    spawn(fn -> perform(id, repository, branch, callback) end)
  end

  def perform(project_identifier, repository, branch, callback, project \\ Dockup.Project,
               deploy_job \\ __MODULE__) do
    project_id = to_string(project_identifier)
    project.clone_repository(project_id, repository, branch)

    # Read config
    # if config can't be read, do the following
    urls = project.project_type(project_id)
    |> deploy_job.deploy(project_id)

    project.wait_till_up(urls)
    success_callback(callback, repository, branch, urls)
  rescue
    error in MatchError ->
      Logger.error (inspect error)
      error_callback(callback, repository, branch, (inspect error))
    e ->
      message = "An unexpected error occured when deploying #{project_identifier} : #{e.message}"
      Logger.error message
      error_callback(callback, repository, branch, message)
  end

  # Given a project type and project id, deploys the app and
  # and returns a list : [{<port>, <http://ip_on_docker:port>, <haikunated_url>} ...]
  def deploy(type, project_id, config_generator \\ Dockup.ConfigGenerator, project \\ Dockup.Project)

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
