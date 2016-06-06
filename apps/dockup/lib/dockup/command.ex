defmodule Dockup.Command do
  require Logger
  @command_module Application.get_env(:dockup, :command_module)

  def run(command, args) do
    @command_module.run(command, args)
  end
end
