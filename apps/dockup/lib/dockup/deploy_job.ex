defmodule Dockup.DeployJob do
  require Logger

  def spawn_process(%{id: id, git_url: repository, branch: branch}, callback) do
    spawn(fn -> perform(id, repository, branch, callback) end)
  end

  def perform(project_identifier, repository, branch, callback \\ Dockup.DefaultCallback.lambda, project \\ Dockup.Project,
               deploy_job \\ __MODULE__) do
    project_id = to_string(project_identifier)

    callback.("cloning_repo", nil)
    project.clone_repository(project_id, repository, branch)

    project_type = project.project_type(project_id)
    callback.("starting", log_url(project_id))
    urls = deploy_job.deploy(project_type, project_id)

    callback.("checking_urls", urls)
    project.wait_till_up(urls)

    callback.("started", urls)
  rescue
    error in MatchError ->
      Logger.error (inspect error)
      callback.("deployment_failed", (inspect error))
    e ->
      message = "An unexpected error occured when deploying #{project_identifier} : #{e.message}"
      Logger.error message
      callback.("deployment_failed", message)
  end

  # Given a project type and project id, deploys the app and
  # and returns %{"<service name>" => [%{"port" => "<container_port>", "url" => <"url">}, ...], ...}
  def deploy(type, project_id, config_generator \\ Dockup.ConfigGenerator, project \\ Dockup.Project)

  def deploy(:unknown, _project_id, _config_generator, _project) do
    Logger.info "Deploying using custom configuration is yet to be turned on."
    #Logger.info "Deploying using custom configuration #{project_id}"
    #project.start(project_id)
  end

  def deploy(type, project_id, config_generator, project) do
    Logger.info "Deploying #{type} #{project_id}"
    config_generator.generate(type, project_id)
    project.start(project_id)
  end

  def log_url(project_id) do
    %{ "log_url" => "/deployment_logs/#?projectName=#{project_id}" }
  end
end
