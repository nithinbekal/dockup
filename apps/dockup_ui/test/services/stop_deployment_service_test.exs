defmodule StopDeploymentServiceTest do
  use DockupUi.ModelCase, async: true

  test "run returns :ok after stopping containers and running service to update status" do
    defmodule FakeStopDeployJob do
      def spawn_process(123, _callback) do
        send self, :stopped_containers
        :ok
      end
    end

    defmodule FakeStatusUpdateService do
      def run("stopping", 123) do
        send self, :status_updated
        :ok
      end
    end

    :ok = DockupUi.StopDeploymentService.run(123, FakeStopDeployJob, FakeStatusUpdateService)
    assert_received :stopped_containers
    assert_received :status_updated
  end
end

