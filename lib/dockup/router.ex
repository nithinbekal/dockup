defmodule Dockup.Router do
  use Plug.Router

  plug :match
  plug :dispatch

  def start_server do
    run_preflight_checks

    port = Dockup.Configs.port
    ip = Dockup.Configs.ip
    {:ok, _} = Plug.Adapters.Cowboy.http __MODULE__, [], [port: port, ip: ip]
  end

  get "/" do
    send_resp(conn, 200, "Hello Plug!")
  end

  match _ do
    send_resp(conn, 404, "Nothing here")
  end

  defp run_preflight_checks do
    # Check if workdir exists
    Dockup.Configs.workdir

    # Check if docker and docker-compose versions are ok
    Dockup.Container.check_docker_version

    # Make sure cache container exists
    Dockup.Container.create_cache_container
  end
end
