defmodule Dockup.FakeCommand do
  require Logger
  @registered_commands %{
    "docker" => %{
      ["run", "--name", "cache", "-v", "/cache", "tianon/true"] => {"", 0},
      ["inspect", "--format='{{.State.Running}}'", "nginx"] => {"true", 0},
      ["-v"] => {"Docker version 1.8.1, build d12ea79", 0},
      ["kill", "-s", "HUP", "nginx"] => {"", 0},
      ["inspect", "--format='{{ range .Mounts }}{{ if eq .Destination \"workdir\" }}{{ .Source }}{{ end }}{{ end }}'", "fake_docker_container_id"] => {"/fake_work_dir_on_host", 0},
    },

    "docker-compose" => %{
      ["-v"] => {"docker-compose version: 1.4.0", 0}
    },

    "git" => %{
      ["clone", "--branch=master", "--depth=1", "https://github.com/code-mancers/project.git", "workdir/code-mancers/project/master"] => {"", 0}
    },

    "hostname" => %{
      [] => {"fake_docker_container_id", 0}
    },
  }

  def run(command, args) do
    {out, exit_status} = @registered_commands[command][args]
    Logger.info "Fake output of command #{command} with args #{inspect args}: '#{out}'"
    {out, exit_status}
  rescue
    MatchError ->
      raise "Dockup.FakeCommand does not know command: '#{command}' with args: #{inspect args}"
  end

  def run(command, args, _dir) do
    run(command, args)
  end
end
