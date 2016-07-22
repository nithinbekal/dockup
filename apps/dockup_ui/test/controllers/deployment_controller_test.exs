defmodule DockupUi.DeploymentControllerTest do
  use DockupUi.ConnCase
  import DockupUi.Factory

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    deployment = insert(:deployment)
    conn = get conn, deployment_path(conn, :index)
    assert json_response(conn, 200)["data"] == [
      %{
        "id" => deployment.id,
        "branch" => deployment.branch,
        "git_url" => deployment.git_url,
        "status" => deployment.status
      }
    ]
  end

  test "shows chosen resource", %{conn: conn} do
    deployment = insert(:deployment)
    conn = get conn, deployment_path(conn, :show, deployment)
    assert json_response(conn, 200)["data"] == %{
      "id" => deployment.id,
      "git_url" => deployment.git_url,
      "branch" => deployment.branch,
      "status" => deployment.status
    }
  end

  test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, deployment_path(conn, :show, -1)
    end
  end

  test "create renders resource when DeployService runs fine", %{conn: conn} do
    deployment = insert(:deployment, %{id: 1})

    defmodule FakeDeployService do
      def run(%{"foo" => "bar"}) do
        {:ok, Repo.get(DockupUi.Deployment, 1)}
      end
    end

    conn = conn |> assign(:deploy_service, FakeDeployService)
    conn = post conn, deployment_path(conn, :create), %{foo: "bar"}
    assert json_response(conn, 201)["data"]["id"] == deployment.id
  end

  test "create renders errors on model when DeployService fails", %{conn: conn} do
    defmodule FakeFailingDeployService do
      def run(%{}) do
        {:error, DockupUi.Deployment.changeset(%DockupUi.Deployment{}, %{})}
      end
    end

    conn = conn |> assign(:deploy_service, FakeFailingDeployService)
    conn = post conn, deployment_path(conn, :create), deployment: %{}
    assert json_response(conn, 422)["errors"] == %{
      "branch" => ["can't be blank"],
      "git_url" => ["can't be blank"]
    }
  end

  test "stop responds with 204 when deployment can be stopped", %{conn: conn} do
    defmodule FakeStopDeploymentService do
      def run(123) do
        :ok
      end
    end

    conn = conn |> assign(:stop_deployment_service, FakeStopDeploymentService)
    conn = post conn, "/api/deployments/123/stop"
    assert response(conn, 204)
  end

  test "stop responds with 422 when deployment cannot be stopped", %{conn: conn} do
    defmodule FailingStopDeploymentService do
      def run(123) do
        {:error, nil}
      end
    end

    conn = conn |> assign(:stop_deployment_service, FailingStopDeploymentService)
    conn = post conn, "/api/deployments/123/stop"
    assert response(conn, 422)
  end
end
