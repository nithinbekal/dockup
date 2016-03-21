defmodule Dockup.Project do
  require Logger

  def clone_repository(repository, branch) do
    workdir = project_id(repository, branch) |> workdir
    Logger.info "Cloning #{repository} : #{branch} into #{workdir}"
    File.mkdir_p!(workdir)
    case Dockup.Command.run("git", ["clone", "--branch=#{branch}", "--depth=1", repository, workdir]) do
      {_out, 0} -> :ok
      {out, _} -> raise out
    end
  rescue
    error ->
      raise DockupException, "Cannot clone #{branch} of #{repository}. Error: #{error.message}"
  end

  def project_id(repository, branch) do
    {org, repo} = parse_repo_from_git_url(repository)
    "#{org}/#{repo}/#{branch}"
  end

  def workdir(app_id) do
    "#{Dockup.Configs.workdir}/#{app_id}"
  end

  defp parse_repo_from_git_url(git_url) do
    %{"org" => org, "repo" => repo} = Regex.named_captures(~r/.*[:\/](?<org>.+)\/(?<repo>.+).git/, git_url)
    {org, repo}
  end
end
