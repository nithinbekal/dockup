defmodule DockupUi.StopDeploymentService do
  alias DockupUi.{
    DeploymentStatusUpdateService
  }

  def run(deployment_id, stop_deployment_job \\ Dockup.StopDeploymentJob, status_update_service \\ DeploymentStatusUpdateService) do
    callback = nil # TODO: Replace this with actual callback function
    with \
      _pid <- stop_deployment_job.spawn_process(deployment_id, callback),
      {:ok, _} <- status_update_service.run("stopping", deployment_id)
    do
      :ok
    end
  end
end

