defmodule Dockup.DeployJob do
  require Logger

  def spawn_process(%{"repository" => repository, "branch" => branch, "callback_url" => callback_url}) do
    spawn(fn -> perform(repository, branch, callback_url) end)
  end

  defp perform(repository, branch, _callback_url) do
    Dockup.Project.clone_repository(repository, branch)

    #success_callback(callback_url, repository, branch, urls)
  rescue
    e in DockupException ->
      Logger.error e.message
      #error_callback(callback_url, repository, branch, e.message)
  end

  #defp error_callback(callback_url, repository, branch, reason) do

  #end

  #defp success_callback(callback_url, repository, branch, urls) do

  #end
end
