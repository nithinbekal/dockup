defmodule Dockup.DeployJob do
  require Logger

  def spawn_process(%{"repository" => repository, "branch" => branch, "callback_url" => callback_url}) do
    spawn(fn -> perform(repository, branch, callback_url) end)
  end

  defp perform(repository, branch, _callback_url) do
    project_id = Dockup.Project.project_id(repository, branch)
    Dockup.Project.clone_repository(repository, branch)

    # Read config
    # if config can't be read, do the following
    Dockup.Project.auto_detect_project_type(project_id)
    |> deploy project_id

    #success_callback(callback_url, repository, branch, urls)
  rescue
    e in DockupException ->
      Logger.error e.message
      #error_callback(callback_url, repository, branch, e.message)
  end

  defp deploy(:static_site, project_id) do
    # TODO
  end

  defp deploy(_, app_id) do
    Logger.error "Don't know how to deploy #{app_id}"
  end

  #defp error_callback(callback_url, repository, branch, reason) do

  #end

  #defp success_callback(callback_url, repository, branch, urls) do

  #end
end
