defmodule DeployServiceTest do
  use DockupUi.ModelCase, async: true

  defmodule FakeDeployJob do
    def spawn_process(_params) do
      send self, :ran_deploy_job
      :ok
    end
  end

  test "run returns {:ok, deployment} if deployment is saved and the job is scheduled" do
    {:ok, deployment} = DockupUi.DeployService.run(%{git_url: "foo", branch: "bar"}, FakeDeployJob)
    %{git_url: "foo", branch: "bar"} = deployment
    assert_received :ran_deploy_job
  end

  test "run returns {:error, changeset} if deployment cannot be saved" do
    {:error, changeset} = DockupUi.DeployService.run(%{branch: "bar"}, FakeDeployJob)
    assert {:git_url, {"can't be blank", []}} in changeset.errors
    refute_received :ran_deploy_job
  end
end
