defmodule Dockup do
  use Application
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do

    children = plug_router_worker

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Dockup.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp plug_router_worker do
    import Supervisor.Spec, warn: false
    if Application.get_env(:dockup, :start_server, true) do
      [worker(Dockup.Router, [], function: :start_server)]
    else
      []
    end
  end
end
