defmodule Dockup.Router do
  use Plug.Router
  require Logger

  plug GhWebhookPlug, secret: Dockup.Configs.github_webhook_secret, path: "/gh-webhook", action: {__MODULE__, :gh_webhook}
  plug :match
  plug :dispatch

  def start_server do
    run_preflight_checks

    port = Dockup.Configs.port
    ip = Dockup.Configs.ip
    {:ok, _} = Plug.Adapters.Cowboy.http __MODULE__, [], [port: port, ip: ip]
  end

  post "/deploy" do
    send_resp(conn, 200, "This should queue an app for deployment") |> halt
  end

  get "/status" do
    send_resp(conn, 200, "This will return a list of all live deployments") |> halt
  end

  post "/destroy" do
    send_resp(conn, 200, "This will return a list of all live deployments") |> halt
  end

  match _ do
    send_resp(conn, 404, "Nothing here") |> halt
  end

  def gh_webhook(payload) do
    Logger.info "Received webhook with payload #{inspect payload}"
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
