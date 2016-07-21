defmodule DockupUi.DeploymentStatusUpdateService do
  alias DockupUi.{
    Deployment,
    Repo
  }

  def run(status, deployment_id) when is_integer(deployment_id) do
    deployment = Repo.get!(Deployment, deployment_id)
    run(status, deployment)
  rescue
    _ -> {:error, deployment_id}
  end

  def run(status, deployment) do
    with \
      changeset <- Deployment.changeset(deployment, %{status: status}),
      {:ok, deployment} <- Repo.update(changeset),
      :ok <- DockupUi.DeploymentChannel.update_deployment_status(deployment)
    do
      {:ok, deployment}
    end
  end
end
