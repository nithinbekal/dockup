defmodule Dockup.ContainerTest do
  use ExUnit.Case
  import ExUnit.CaptureLog

  test "create_cache_container creates a cache container if it does not exist" do
    defmodule CacheCreationCommand do
      def run(cmd, args) do
        send self(), {cmd, args}
        {:ok, 0}
      end
    end

    Dockup.Container.create_cache_container(CacheCreationCommand)

    [cmd | args] = String.split("docker run --name cache -v /cache tianon/true")
    receive do
      {command, arguments} ->
        assert command == cmd
        assert arguments == args
    end
  end

  test "create_cache_container does nothing and logs warning if cache container already exists" do
    defmodule CacheExistsCommand do
      def run(_cmd, _args) do
        {:ok, 1}
      end
    end

    assert capture_log(fn ->
      Dockup.Container.create_cache_container(CacheExistsCommand)
    end) =~ "Cannot create docker container cache. It may already exist"
  end

  test "check_docker_version raises exception if docker version is incompatible" do
    defmodule OldDockerVersionCommand do
      def run(cmd, args) do
        case {cmd, args} do
          {"docker", ["-v"]} -> {"Docker version 1.7", 0}
          {"docker-compose",  ["-v"]} -> {"docker-compose version 1.4", 0}
        end
      end
    end

    try do
      Dockup.Container.check_docker_version(OldDockerVersionCommand)
    rescue
      exception -> assert exception.message == "Docker version should be >= 1.8"
    end
  end

  test "check_docker_version raises exception if docker-compose version is incompatible" do
    defmodule OldDockerComposeVersionCommand do
      def run(cmd, args) do
        case {cmd, args} do
          {"docker", ["-v"]} -> {"Docker version 1.8", 0}
          {"docker-compose",  ["-v"]} -> {"docker-compose version 1.3", 0}
        end
      end
    end

    try do
      Dockup.Container.check_docker_version(OldDockerComposeVersionCommand)
    rescue
      exception -> assert exception.message == "docker-compose version should be >= 1.4"
    end
  end

  test "check_docker_version does not raise any exception if versions are compatible" do
    defmodule MatchingDockerVersion do
      def run(cmd, args) do
        case {cmd, args} do
          {"docker", ["-v"]} -> {"Docker version 1.8", 0}
          {"docker-compose",  ["-v"]} -> {"docker-compose version 1.4", 0}
        end
      end
    end

    Dockup.Container.check_docker_version(MatchingDockerVersion)
  end

  test "run_nginx_container starts nginx container if it exists" do
    defmodule NginxCommand do
      def run(cmd, args) do
        case {cmd, args} do
          {"docker",  ["inspect", "--format='{{.State.Running}}'", "nginx"]} ->
            {"false", 0}
          {"docker", ["start", "nginx"]} -> {"okay", 0}
        end
      end
    end

    logs = capture_log(fn -> Dockup.Container.run_nginx_container(NginxCommand) end)
    assert logs =~ "Nginx container seems to be down. Trying to start"
    assert logs =~ "Nginx started"
  end

  test "run_nginx_container pulls and starts nginx container if it does not exist" do
    defmodule NginxDoesNotExistCommand do
      def run(cmd, args) do
        case {cmd, args} do
          {"docker",  ["inspect", "--format='{{.State.Running}}'", "nginx"]} ->
            {"fake output", 1}
          {"docker", _} -> {"okay", 0}
        end
      end
    end

    logs = capture_log(fn -> Dockup.Container.run_nginx_container(NginxDoesNotExistCommand) end)
    assert logs =~ "Nginx container not found."
    assert logs =~ "Trying to pull nginx image"
    assert logs =~ "Nginx pulled and started"
  end
end

