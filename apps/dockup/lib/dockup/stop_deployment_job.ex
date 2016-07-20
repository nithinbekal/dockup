defmodule Dockup.StopDeploymentJob do
  require Logger

  def spawn_process({id, callback}) do
    spawn(fn -> perform(id, callback) end)
  end

  # TODO: Implement callbacks
  def perform(project_identifier, _callback, project \\ Dockup.Project) do
    project_id = to_string(project_identifier)
    project.stop(project_id)
  rescue
    error in MatchError ->
      Logger.error (inspect error)
    e ->
      message = "An unexpected error occured when deploying #{project_identifier} : #{e.message}"
      Logger.error message
  end
end
