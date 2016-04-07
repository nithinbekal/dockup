defmodule Dockup do
  use Application
  import Supervisor.Spec

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do

    children = if Application.get_env(:dockup, :start_server, true) do
      [
        worker(Dockup.Router, [], function: :start_server),
        worker(Dockup.ProjectIndex, [], function: :start)
      ]
    else
      []
    end

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Dockup.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp plug_router_worker do
    if Application.get_env(:dockup, :start_server, true) do
      [worker(Dockup.Router, [], function: :start_server)]
    else
      []
    end
  end

  defp project_index_store_worker do
    [worker(Dockup.ProjectIndex, [], function: :start)]
  end
end
