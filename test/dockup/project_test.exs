defmodule Dockup.ProjectTest do
  use ExUnit.Case, async: true

  test "project_id is of the format org_name/repo_name/branch for github https url" do
    id = Dockup.Project.project_id("https://github.com/code-mancers/dockup.git", "master")
    assert id == "code-mancers/dockup/master"
  end

  test "project_id is of the format org_name/repo_name/branch for github ssh url" do
    id = Dockup.Project.project_id("git@github.com:code-mancers/dockup.git", "master")
    assert id == "code-mancers/dockup/master"
  end

  test "project_id is of the format org_name/repo_name/branch for gitlab ssh url" do
    id = Dockup.Project.project_id("git@your_server.com:code-mancers/dockup.git", "master")
    assert id == "code-mancers/dockup/master"
  end

  test "project_dir of a project is <Dockup workdir>/<project_id>" do
    assert Dockup.Project.project_dir("foo/test/baz") == "#{Dockup.Configs.workdir}/foo/test/baz"
  end

  # Remove mocking in favor of dependency injection and make this test pass
  test "clone_repository clones the given branch of git repository into project_dir" do
    repository = "https://github.com/code-mancers/dockup.git"
    branch = "master"
    project_dir = Dockup.Project.project_id(repository, branch) |> Dockup.Project.project_dir

    defmodule GitCloneCommand do
      def run(cmd, args) do
        send self(), {cmd, args}
        {"", 0}
      end
    end
    Dockup.Project.clone_repository(repository, branch, GitCloneCommand)
    [cmd | args] = String.split("git clone --branch=master --depth=1 #{repository} #{project_dir}")

    receive do
      {command, arguments} ->
        assert command == cmd
        assert arguments == args
    end
  end

  # Remove mocking in favor of dependency injection and make this test pass
  test "clone_repository raises an exception when clone command fails" do
    repository = "https://github.com/code-mancers/dockup.git"
    branch = "master"

    defmodule FailingGitCloneCommand do
      def run(_cmd, _args) do
        {"cannot clone this shitz", 1}
      end
    end
    try do
      Dockup.Project.clone_repository(repository, branch, FailingGitCloneCommand)
    rescue
      error ->
        assert error.message == "Cannot clone #{branch} of #{repository}. Error: cannot clone this shitz"
    end
  end

  test "auto_detect_project_type returns :static_site if index.html is found" do
    project_id = "auto/detect/static"
    project_dir = Dockup.Project.project_dir project_id
    File.mkdir_p project_dir
    File.touch "#{project_dir}/index.html"

    assert Dockup.Project.auto_detect_project_type(project_id) == :static_site
    File.rm_rf Dockup.Configs.workdir <> "/auto"
  end

  test "auto_detect_project_type returns :unknown if auto detection fails" do
    project_id = "auto/detect/none"
    project_dir = Dockup.Project.project_dir project_id
    File.mkdir_p project_dir

    assert Dockup.Project.auto_detect_project_type(project_id) == :unknown
    File.rm_rf Dockup.Configs.workdir <> "/auto"
  end
end
