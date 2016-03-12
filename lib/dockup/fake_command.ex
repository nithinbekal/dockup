defmodule Dockup.FakeCommand do
  require Logger
  @registered_commands %{
    "docker" => %{
      ["run", "--name", "cache", "-v", "/cache", "tianon/true"] => {"", 0},
      ["-v"] => {"Docker version 1.8.1, build d12ea79", 0},
    },

    "docker-compose" => %{
      ["-v"] => {"docker-compose version: 1.4.0", 0}
    },

    "git" => %{
      ["clone", "--branch=master", "--depth=1", "https://github.com/code-mancers/project.git", "./workdir/code-mancers/project/master"] => {"", 0}
    }
  }

  def run(command, args) do
    {out, exit_status} = @registered_commands[command][args]
    Logger.info "Fake output of command #{command} with args #{inspect args}: '#{out}'"
    {out, exit_status}
  rescue
    MatchError ->
      raise "Dockup.FakeCommand does not know command: '#{command}' with args: #{inspect args}"
  end
end
