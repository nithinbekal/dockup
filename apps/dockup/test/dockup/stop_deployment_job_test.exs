defmodule Dockup.StopDeploymentJobTest do
  use ExUnit.Case, async: true

  test "performing a StopDeploymentJob sends 'stop' to the project" do
    defmodule FakeProject do
      def stop("123"), do: send(self, :stop_received)
    end

    Dockup.StopDeploymentJob.perform(123, "fake_callback", FakeProject)
    assert_received :stop_received
  end
end
