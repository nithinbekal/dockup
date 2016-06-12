defmodule Dockup.DeployJobTest do
  use ExUnit.Case, async: true

  test "deploying static site writes nginx config and reloads nginx container" do
    defmodule FakeProject do
      def project_id("fake_repo", "fake_branch"), do: "fake_project_id"
      def clone_repository(_repo, _branch), do: :ok
      def auto_detect_project_type("fake_project_id"), do: :static_site
      def wait_till_up(_urls), do: :ok
    end

    defmodule FakeNginxConfig do
      def write_config(:static_site, "fake_project_id"), do: send self, :nginx_config_added
    end

    defmodule FakeContainer do
      def reload_nginx, do: send self, :nginx_reloaded
    end

    defmodule FakeCallback do
      def deployment_success(_repo, _branch, _urls, callback_url), do: send self, {:callback_triggered, callback_url}
    end

    Dockup.DeployJob.perform("fake_repo", "fake_branch", {FakeCallback, "fake_callback_url"},
                             FakeProject, FakeNginxConfig, FakeContainer)
    assert_received :nginx_config_added
    assert_received :nginx_reloaded
    assert_received {:callback_triggered, "fake_callback_url"}
  end
end
