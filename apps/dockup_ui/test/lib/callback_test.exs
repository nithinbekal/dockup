defmodule DockupUi.CallbackTest do
  use DockupUi.ModelCase, async: true
  import DockupUi.Factory

  alias DockupUi.Callback

  test "lambda returns a function" do
    deployment = insert(:deployment)
    assert is_function(Callback.lambda(deployment))
  end

  test "callback runs DeploymentStatusUpdateService" do
    defmodule FakeStatusUpdateService do
      def run("fake_event", 1, "fake_payload") do
        send self, :status_updated
      end
    end

    deployment = insert(:deployment, id: 1)
    lambda = Callback.lambda(deployment, FakeStatusUpdateService)
    lambda.("fake_event", "fake_payload")
    assert_received :status_updated
  end
end
