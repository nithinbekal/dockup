defmodule Dockup.ProjectTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureLog

  test "project_dir of a project is <Dockup workdir>/<project_id>" do
    assert Dockup.Project.project_dir("foo") == "#{Dockup.Configs.workdir}/foo"
  end

  # Remove mocking in favor of dependency injection and make this test pass
  test "clone_repository clones the given branch of git repository into project_dir" do
    repository = "https://github.com/code-mancers/dockup.git"
    branch = "master"
    project_dir = Dockup.Project.project_dir("foo")

    defmodule GitCloneCommand do
      def run(cmd, args) do
        send self(), {cmd, args}
        {"", 0}
      end
    end
    Dockup.Project.clone_repository("foo", repository, branch, GitCloneCommand)
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
      Dockup.Project.clone_repository("foo", repository, branch, FailingGitCloneCommand)
    rescue
      error ->
        assert error.message == "Cannot clone #{branch} of #{repository}. Error: cannot clone this shitz"
    end
  end

  test "project_type returns :jekyll_site if project uses jekyll gem" do
    project_id = "auto/detect/jekyll"
    project_dir = Dockup.Project.project_dir project_id
    File.mkdir_p project_dir
    File.write! "#{project_dir}/Gemfile", """
      source "https://rubygems.org"

      gem 'capistrano', '~> 2.15'
      gem 'jekyll'
    """

    assert Dockup.Project.project_type(project_id) == :jekyll_site
    File.rm_rf Dockup.Configs.workdir <> "/auto"
  end

  test "project_type returns :jekyll_site if project uses jekyll gem and index.html file is also present" do
    project_id = "auto/detect/jekyll"
    project_dir = Dockup.Project.project_dir project_id
    File.mkdir_p project_dir
    File.write! "#{project_dir}/Gemfile", """
      source "https://rubygems.org"

      gem 'capistrano', '~> 2.15'
      gem 'jekyll'
    """
    File.touch "#{project_dir}/index.html"

    assert Dockup.Project.project_type(project_id) == :jekyll_site
    File.rm_rf Dockup.Configs.workdir <> "/auto"
  end

  test "project_type returns :static_site if index.html is found" do
    project_id = "auto/detect/static"
    project_dir = Dockup.Project.project_dir project_id
    File.mkdir_p project_dir
    File.touch "#{project_dir}/index.html"

    assert Dockup.Project.project_type(project_id) == :static_site
    File.rm_rf Dockup.Configs.workdir <> "/auto"
  end

  test "project_type returns :unknown if auto detection fails" do
    project_id = "auto/detect/none"
    project_dir = Dockup.Project.project_dir project_id
    File.mkdir_p project_dir

    assert Dockup.Project.project_type(project_id) == :unknown
    File.rm_rf Dockup.Configs.workdir <> "/auto"
  end

  test "wait_till_up waits until http response of url is 200" do
    Agent.start_link(fn -> 1 end, name: RetryCount)
    defmodule FakeHttp do
      def get_status("dummy_url") do
        count = Agent.get(RetryCount, fn count -> count end)
        Agent.update(RetryCount, fn count -> count+1 end)
        if count == 3, do: 200, else: 404
      end
    end

    urls = [{"80", "fake_proxy", "dummy_url"}]
    logs = capture_log(fn -> Dockup.Project.wait_till_up(urls, FakeHttp, 0) end)
    assert logs =~ "Attempt 1 failed"
    assert logs =~ "Attempt 2 failed"
    refute logs =~ "Attempt 3 failed"

    Agent.stop(RetryCount)
  end

  test "project_dir_on_host host returns the dir of project on host" do
    defmodule FakeContainer do
      def workdir_on_host do
        "/fake_workdir"
      end
    end
    assert Dockup.Project.project_dir_on_host("foo", FakeContainer) == "/fake_workdir/foo"
  end

  test "start starts all containers, writes nginx config and restarts nginx container" do
    defmodule FakeContainerForStarting do
      def start_containers("foo"), do: send self, :containers_started
      def port_mappings("foo"), do: "fake_ports"
      def reload_nginx, do: send self, :nginx_reloaded
    end

    defmodule FakeNginxConfigForStarting do
      def write_config("foo", "fake_ports"), do: send self, :nginx_config_written
    end

    Dockup.Project.start("foo", FakeContainerForStarting, FakeNginxConfigForStarting)

    assert_received :containers_started
    assert_received :nginx_config_written
    assert_received :nginx_reloaded
  end
end
