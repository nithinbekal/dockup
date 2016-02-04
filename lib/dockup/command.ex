defmodule Dockup.Command do
  def run(command, args) do
    System.cmd(command, args, into: IO.stream(:stdio, :line))
  end
end
