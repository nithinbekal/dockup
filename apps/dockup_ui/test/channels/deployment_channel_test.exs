defmodule DockupUi.DeploymentChannelTest do
  use DockupUi.ChannelCase

  alias DockupUi.DeploymentChannel

  test "new_deployment broadcasts a new_deployment event" do
    DockupUi.Endpoint.subscribe("deployments:all")
    DeploymentChannel.new_deployment(%{foo: "bar"})
    assert_receive %Phoenix.Socket.Broadcast{
      topic: "deployments:all",
      event: "new_deployment",
      payload: %{foo: "bar"}}
  end

  test "update_deployment_status broadcasts an update_status event" do
    DockupUi.Endpoint.subscribe("deployments:all")
    DeploymentChannel.update_deployment_status(%{foo: "bar"})
    assert_receive %Phoenix.Socket.Broadcast{
      topic: "deployments:all",
      event: "update_status",
      payload: %{foo: "bar"}}
  end
end
