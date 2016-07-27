defmodule DockupUi.DeployService do
  alias DockupUi.{
    Deployment,
    Repo
  }

  def run(deployment_params, deploy_job \\ Dockup.DeployJob) do
    with \
      changeset <- Deployment.changeset(%Deployment{status: "queued"}, deployment_params),
      {:ok, deployment} <- Repo.insert(changeset),
      :ok <- deploy_project(deploy_job, deployment),
      :ok <- DockupUi.DeploymentChannel.new_deployment(deployment)
    do
      {:ok, deployment}
    end
  end

  defp deploy_project(deploy_job, deployment, callback \\ DockupUi.Callback) do
    deploy_job.spawn_process(deployment, callback.lambda(deployment))
    :ok
  end
end
