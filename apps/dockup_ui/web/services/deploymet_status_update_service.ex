defmodule DockupUi.DeploymentStatusUpdateService do
  # This module is responsible for updating the status of the deployment
  # in the DB as well as broadcasting the status update over the websocket.

  require Logger

  alias DockupUi.{
    Deployment,
    Repo,
    DeploymentChannel
  }

  def run(status, deployment_id, payload \\ nil, channel \\ DeploymentChannel)

  def run(status, deployment_id, payload, channel) when is_integer(deployment_id) do
    deployment = Repo.get!(Deployment, deployment_id)
    run(status, deployment, payload, channel)
  rescue
    _ ->
      Logger.error "Cannot update status: #{status} of deployment_id: #{deployment_id}"
      {:error, deployment_id}
  end

  def run(status, deployment, payload, channel) do
    with \
      changeset <- Deployment.changeset(deployment, %{status: status}),
      {:ok, deployment} <- Repo.update(changeset),
      :ok <- channel.update_deployment_status(deployment, payload)
    do
      {:ok, deployment}
    end
  end
end
