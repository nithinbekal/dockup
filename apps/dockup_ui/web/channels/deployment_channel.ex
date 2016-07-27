defmodule DockupUi.DeploymentChannel do
  use Phoenix.Channel

  def new_deployment(deployment) do
    deployment_event("deployment_created", deployment)
  end

  def update_deployment_status(deployment, payload) do
    deployment_event("status_updated", %{deployment: deployment, payload: payload})
  end

  #============== Internal API below=============#

  def deployment_event(event, deployment) do
    DockupUi.Endpoint.broadcast("deployments:all", event, deployment)
  end

  def join("deployments:all", _message, socket) do
    {:ok, socket}
  end
end
