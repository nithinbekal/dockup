defmodule Dockup.ProjectTest do
  use ExUnit.Case

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

  test "workdir of a project is <Dockup workdir>/<project_id>" do
    assert Dockup.Project.workdir("foo/bar/baz") == "./workdir/foo/bar/baz"
  end

  test "clone_repository clones the given branch of git repository into workdir" do
    repository = "https://github.com/code-mancers/dockup.git"
    branch = "master"
    workdir = Dockup.Project.project_id(repository, branch) |> Dockup.Project.workdir

    :meck.new(Dockup.Command)
    :meck.expect(Dockup.Command, :run, fn (_cmd, _args) -> {"", 0} end)
    Dockup.Project.clone_repository(repository, branch)
    [cmd | args] = String.split("git clone --branch=master --depth=1 #{repository} #{workdir}")
    assert :meck.called(Dockup.Command, :run, [cmd, args])
    :meck.validate(Dockup.Command)
    :meck.unload(Dockup.Command)
  end

  test "clone_repository raises an exception when clone command fails" do
    repository = "https://github.com/code-mancers/dockup.git"
    branch = "master"
    workdir = Dockup.Project.project_id(repository, branch) |> Dockup.Project.workdir

    :meck.new(Dockup.Command)
    :meck.expect(Dockup.Command, :run, fn (_cmd, _args) -> {"cannot clone this shitz", 1} end)
    try do
      Dockup.Project.clone_repository(repository, branch)
    rescue
      error ->
        assert error.message == "Cannot clone #{branch} of #{repository}. Error: cannot clone this shitz"
    end
    :meck.unload(Dockup.Command)
  end
end

