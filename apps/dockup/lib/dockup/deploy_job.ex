defmodule Dockup.DeployJob do
  require Logger

  alias Dockup.{
    DefaultCallback,
    Project,
  }

  def spawn_process(%{id: id, git_url: repository, branch: branch}, callback) do
    spawn(fn -> perform(id, repository, branch, callback) end)
  end

  def perform(project_identifier, repository, branch,
              callback \\ DefaultCallback.lambda, deps \\ []) do
    project    = deps[:project]    || Project
    deploy_job = deps[:deploy_job] || __MODULE__

    project_id = to_string(project_identifier)

    callback.("cloning_repo", nil)
    project.clone_repository(project_id, repository, branch)

    project_type = project.project_type(project_id)
    callback.("starting", nil)
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

  @doc """
  Given a project type and project id, deploys the app and
  and returns a list : [{<port>, <http://ip_on_docker:port>, <haikunated_url>} ...]
  """
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
end
