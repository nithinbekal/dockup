defmodule DeploymentStatusUpdateServiceTest do
  use DockupUi.ModelCase, async: true
  import DockupUi.Factory

  defmodule FakeChannel do
    def update_deployment_status(_params, "fake_payload") do
      send self, :status_updated_on_channel
      :ok
    end

    def update_deployment_status(_params, _payload), do: :ok
  end

  @service_urls %{ "web" => [
    %{"port" => "8000", "url" => "http://random_string_1.dockup.codemancers.com"},
    %{"port" => "4000", "url" => "http://random_string_2.dockup.codemancers.com"}
  ]}

  test "run returns {:ok, deployment} after updating the DB and broadcasting status update of deployment" do
    deployment = insert(:deployment)
    {:ok, updated_deployment} = DockupUi.DeploymentStatusUpdateService.run("foo", deployment.id, "fake_payload", FakeChannel)

    assert updated_deployment.status == "foo"
    assert updated_deployment.service_urls == nil
    assert_received :status_updated_on_channel
  end

  test "run returns {:ok, deployment} and persists payload" do
    deployment = insert(:deployment)
    {:ok, _deployment} =
      DockupUi.DeploymentStatusUpdateService.run("started", deployment.id, @service_urls, FakeChannel)

    updated_deployment = DockupUi.Repo.get(DockupUi.Deployment, deployment.id)

    assert updated_deployment.status == "started"
    assert updated_deployment.service_urls == @service_urls
  end

  test "run returns {:error, deployment_id} if deployment not found" do
    {:error, 123} = DockupUi.DeploymentStatusUpdateService.run("foo", 123, FakeChannel)
    refute_received :status_updated_on_channel
  end
end
