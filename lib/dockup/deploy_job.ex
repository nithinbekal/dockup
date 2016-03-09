defmodule DeployJob do
  require Logger

  def spawn_process(%{"repository" => repository, "branch" => branch, "callback_url" => callback_url}) do
    spawn(fn -> perform(repository, branch, callback_url) end)
  end

  defp perform(repository, branch, callback_url) do
    #clone_repository(repository, branch)
    copy_template_files()

    #u
    success_callback(callback_url, repository, branch, urls)
  rescue
    e in DockupException ->
      Logger.error e.message
      error_callback(callback_url, repository, branch, e.message)
  end

  defp error_callback(callback_url, repository, branch, reason) do

  end

  defp success_callback(callback_url, repository, branch, urls) do

  end
end
