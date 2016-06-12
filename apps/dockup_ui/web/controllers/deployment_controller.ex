defmodule DockupUi.DeploymentController do
  use DockupUi.Web, :controller

  alias DockupUi.{
    Deployment,
    DeployService
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
end
