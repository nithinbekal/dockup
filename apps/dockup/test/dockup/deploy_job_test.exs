defmodule Dockup.DeployJobTest do
  use ExUnit.Case, async: true

  defmodule FakeProject do
    def clone_repository("123", "fake_repo", "fake_branch"), do: :ok
    def project_type("123"), do: :static_site
    def wait_till_up(_urls), do: :ok
  end

  defmodule FakeNginxConfig do
    def write_config(:static_site, "fake_project_id"), do: send self, :nginx_config_added
  end

  defmodule FakeCallback do
    def lambda do
      fn(event, payload) ->
        send self, {event, payload}
      end
    end
  end

  defmodule FakeDeployJob do
    def deploy(:static_site, "123") do
      "fake_urls"
    end
  end

  test "performing a deployment triggers deployment using the project type" do
    Dockup.DeployJob.perform(123, "fake_repo", "fake_branch", FakeCallback.lambda,
                             FakeProject, FakeDeployJob)
    assert_received {"cloning_repo", nil}
    assert_received {"starting", %{"log_url" => "/deployment_logs/#?projectName=123"}}
    assert_received {"checking_urls", "fake_urls"}
    assert_received {"started", "fake_urls"}
  end

  test "triggers deployment_failed callback when an exception occurs" do
    defmodule FailingDeployJob do
      def deploy(:static_site, "123") do
        raise "ifuckedup"
      end
    end
    Dockup.DeployJob.perform(123, "fake_repo", "fake_branch", FakeCallback.lambda,
                             FakeProject, FailingDeployJob)
    assert_received {"deployment_failed", "An unexpected error occured when deploying 123 : ifuckedup"}
  end
end
