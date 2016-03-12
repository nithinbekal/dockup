defmodule DeployJob do
  require Logger

  def spawn_process(%{"repository" => repository, "branch" => branch, "callback_url" => callback_url}) do
    spawn(fn -> perform(repository, branch, callback_url) end)
  end

  defp perform(repository, branch, callback_url) do
    clone_repository(repository, branch)

    #success_callback(callback_url, repository, branch, urls)
  rescue
    e in DockupException ->
      Logger.error e.message
      #error_callback(callback_url, repository, branch, e.message)
  end

  def app_id(repository, branch) do
    {org, repo} = parse_repo_from_git_url(repository)
    "#{org}/#{repo}/#{branch}"
  end

  #defp error_callback(callback_url, repository, branch, reason) do

  #end

  #defp success_callback(callback_url, repository, branch, urls) do

  #end

  defp clone_repository(repository, branch) do
    IO.puts branch_dir(app_id(repository, branch))
    branch_dir = app_id(repository, branch) |> branch_dir
    File.mkdir_p!(branch_dir)
    case Dockup.Command.run("git", ["clone", "--branch=#{branch}", "--depth=1", repository, branch_dir]) do
      {_out, 0} -> :ok
      {out, _} -> raise out
    end
  rescue
    error ->
      raise DockupException, "Cannot clone #{branch} of #{repository}. Error: #{error.message}"
  end

  defp branch_dir(app_id) do
    "#{Dockup.Configs.workdir}/#{app_id}"
  end

  defp parse_repo_from_git_url(git_url) do
    %{"org" => org, "repo" => repo} = Regex.named_captures(~r/.*[:\/](?<org>.+)\/(?<repo>.+).git/, git_url)
    {org, repo}
  end
end
