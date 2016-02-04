require Logger

defmodule Dockup.Command do
  def run(command, args) do
    {out, exit_status} = System.cmd(command, args)
    Logger.info "Running command #{command} with args #{inspect args}"
    Logger.info out
    {out, exit_status}
  end
end
