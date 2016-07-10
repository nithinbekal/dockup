defmodule Dockup.ShellCommand do
  require Logger

  #TODO: to be removed
  def run(command, args) do
    {out, exit_status} = System.cmd(command, args)
    Logger.info "Output of command #{command} with args #{inspect args}: #{out}"
    {String.strip(out), exit_status}
  end

  def run(command, args, dir) do
    {out, exit_status} = System.cmd(command, args, cd: dir)
    Logger.info "Output of command #{command} with args #{inspect args}: #{out}"
    {String.strip(out), exit_status}
  end
end
