defmodule DockupUi.DeploymentChannel do
  use Phoenix.Channel

  def join("deployments:all", _message, socket) do
    {:ok, socket}
  end
end
