defmodule DeploymentStatusUpdateServiceTest do
  use DockupUi.ModelCase, async: true
  import DockupUi.Factory

  defmodule FakeChannel do
    def update_deployment_status(_params, "fake_payload") do
      send self, :status_updated_on_channel
      :ok
    end
  end

  test "run returns {:ok, deployment} after updating the DB and broadcasting status update of deployment" do
    deployment = insert(:deployment)
    {:ok, updated_deployment} = DockupUi.DeploymentStatusUpdateService.run("foo", deployment.id, "fake_payload", FakeChannel)
    assert updated_deployment.status == "foo"
    assert_received :status_updated_on_channel
  end

  test "run returns {:error, deployment_id} if deployment not found" do
    {:error, 123} = DockupUi.DeploymentStatusUpdateService.run("foo", 123, FakeChannel)
    refute_received :status_updated_on_channel
  end
end
