defmodule DockupUi.StopDeploymentService do
  alias DockupUi.{
    Deployment,
    Repo
  }

  def run(deployment_id, stop_deployment_job \\ Dockup.StopDeploymentJob) do
    callback = nil # TODO: Replace this with actuall callback function
    with \
      _pid <- stop_deployment_job.spawn_process(deployment_id, callback),
      {:ok, _} <- DockupUi.DeploymentStatusUpdateService.run("stopping", deployment_id)
    do
      :ok
    end
  end
end

