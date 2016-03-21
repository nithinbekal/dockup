defmodule Dockup.Router do
  use Plug.Router
  require Logger

  plug GhWebhookPlug, secret: Dockup.Configs.github_webhook_secret, path: "/gh-webhook", action: {__MODULE__, :gh_webhook}
  plug Plug.Parsers, parsers: [:json], json_decoder: Poison, pass: ["application/json"]
  plug :match
  plug :dispatch

  def start_server do
    run_preflight_checks

    port = Dockup.Configs.port
    ip = Dockup.Configs.ip
    Logger.info "Serving dockup on port #{port}"
    {:ok, _} = Plug.Adapters.Cowboy.http __MODULE__, [], [port: port, ip: ip]
  end

  post "/deploy" do
    case parse_deploy_params(conn) do
      :error ->
        Logger.error "Received bad parameters to /deploy: #{inspect conn.params}"
        send_resp(conn, 400, "Bad request")
      params ->
        Logger.info "Deploying: #{inspect conn.params}"
        Dockup.DeployJob.spawn_process(params)
        send_resp(conn, 200, "OK")
    end
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

    # Make sure nginx container is running
    Dockup.Container.run_nginx_container
  end

  defp parse_deploy_params(conn) do
    %{"repository" => _a, "branch" => _b, "callback_url" => _c} = conn.params
  rescue
    MatchError ->
      :error
  end
end
