defmodule Dockup.DeployJobTest do
  use ExUnit.Case, async: true

  test "performing a deployment triggers deployment using the project type" do
    defmodule FakeProject do
      def clone_repository("123", "fake_repo", "fake_branch"), do: :ok
      def project_type("123"), do: :static_site
      def wait_till_up(_urls), do: :ok
    end

    defmodule FakeNginxConfig do
      def write_config(:static_site, "fake_project_id"), do: send self, :nginx_config_added
    end

    defmodule FakeCallback do
      def deployment_success(_repo, _branch, urls, callback_url), do: send self, {:callback_triggered, callback_url, urls}
    end

    defmodule FakeDeployJob do
      def deploy(:static_site, "123") do
        "fake_urls"
      end
    end

    Dockup.DeployJob.perform(123, "fake_repo", "fake_branch", {FakeCallback, "fake_callback_url"},
                             FakeProject, FakeDeployJob)
    assert_received {:callback_triggered, "fake_callback_url", "fake_urls"}
  end
end
