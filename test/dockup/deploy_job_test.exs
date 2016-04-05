defmodule Dockup.DeployJobTest do
  use ExUnit.Case

  test "deploying static site writes nginx config and reloads nginx container" do
    defmodule FakeProject do
      def project_id("fake_repo", "fake_branch"), do: "fake_project_id"
      def clone_repository(_repo, _branch), do: :ok
      def auto_detect_project_type("fake_project_id"), do: :static_site
    end

    defmodule FakeNginxConfig do
      def write_config(:static_site, "fake_project_id"), do: send self, :nginx_config_added
    end

    defmodule FakeContainer do
      def reload_nginx, do: send self, :nginx_reloaded
    end

    Dockup.DeployJob.perform("fake_repo", "fake_branch", "fake_callback_url",
                             FakeProject, FakeNginxConfig, FakeContainer)
    assert_received :nginx_config_added
    assert_received :nginx_reloaded
  end
end
