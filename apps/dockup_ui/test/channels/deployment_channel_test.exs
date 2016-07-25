defmodule DockupUi.DeploymentChannelTest do
  use DockupUi.ChannelCase

  alias DockupUi.DeploymentChannel

  test "new_deployment broadcasts a deployment_created event" do
    DockupUi.Endpoint.subscribe("deployments:all")
    DeploymentChannel.new_deployment(%{foo: "bar"})
    assert_receive %Phoenix.Socket.Broadcast{
      topic: "deployments:all",
      event: "deployment_created",
      payload: %{foo: "bar"}}
  end

  test "update_deployment_status broadcasts an status_updated event" do
    DockupUi.Endpoint.subscribe("deployments:all")
    DeploymentChannel.update_deployment_status(%{foo: "bar"}, "payload")
    assert_receive %Phoenix.Socket.Broadcast{
      topic: "deployments:all",
      event: "status_updated",
      payload: %{deployment: %{foo: "bar"}, payload: "payload"}
    }
  end
end
