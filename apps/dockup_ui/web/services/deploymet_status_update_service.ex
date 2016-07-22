defmodule DockupUi.DeploymentStatusUpdateService do
  alias DockupUi.{
    Deployment,
    Repo,
    DeploymentChannel
  }

  def run(status, deployment_id, channel \\ DeploymentChannel)

  def run(status, deployment_id, channel) when is_integer(deployment_id) do
    deployment = Repo.get!(Deployment, deployment_id)
    run(status, deployment, channel)
  rescue
    _ -> {:error, deployment_id}
  end

  def run(status, deployment, channel) do
    with \
      changeset <- Deployment.changeset(deployment, %{status: status}),
      {:ok, deployment} <- Repo.update(changeset),
      :ok <- channel.update_deployment_status(deployment)
    do
      {:ok, deployment}
    end
  end
end
