defmodule DockupUi.DeploymentChannel do
  use Phoenix.Channel

  def deployment_event(event, deployment) do
    DockupUi.Endpoint.broadcast("deployments:all", event, deployment)
  end

  #============== Internal API below=============#

  def join("deployments:all", _message, socket) do
    {:ok, socket}
  end
end
