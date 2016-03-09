defmodule Dockup.ShellCommand do
  require Logger
  def run(command, args) do
    {out, exit_status} = System.cmd(command, args)
    Logger.info "Output of command #{command} with args #{inspect args}: #{out}"
    {out, exit_status}
  end
end
