defmodule DockupUi.DeploymentController do
  use DockupUi.Web, :controller

  alias DockupUi.{
    Deployment,
    DeployService,
    StopDeploymentService
  }

  def index(conn, _params) do
    deployments = Repo.all(Deployment)
    render(conn, "index.json", deployments: deployments)
  end

  def create(conn, deployment_params) do
    deploy_service = conn.assigns[:deploy_service] || DeployService
    case deploy_service.run(deployment_params) do
      {:ok, deployment} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", deployment_path(conn, :show, deployment))
        |> render("show.json", deployment: deployment)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(DockupUi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    deployment = Repo.get!(Deployment, id)
    render(conn, "show.json", deployment: deployment)
  end

  def stop(conn, %{"id" => id}) do
    stop_deployment_service = conn.assigns[:stop_deployment_service] || StopDeploymentService
    case stop_deployment_service.run(String.to_integer(id)) do
      :ok ->
        conn
        |> send_resp(:no_content, "")
      {:error, _} ->
        conn
        |> send_resp(:unprocessable_entity, "")
    end
  end
end
