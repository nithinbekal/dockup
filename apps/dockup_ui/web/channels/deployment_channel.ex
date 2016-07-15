defmodule DockupUi.DeploymentChannel do
  use Phoenix.Channel

  def new_deployment(deployment) do
    deployment_event("new_deployment", deployment)
  end

  def update_deployment_status(deployment) do
    deployment_event("update_status", deployment)
  end

  #============== Internal API below=============#

  def deployment_event(event, deployment) do
    DockupUi.Endpoint.broadcast("deployments:all", event, deployment)
  end

  def join("deployments:all", _message, socket) do
    {:ok, socket}
  end
end
