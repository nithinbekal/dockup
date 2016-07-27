defmodule DockupUi.Callback do
  # Events and descriptions:
  # "queued" - All deployments are created with this initial status.
  # "cloning_repo" - Called before cloning git repo. No payload.
  # "starting" - Called when docker containers are being started. No payload.
  # "checking_urls" - Called when docker containers are started and haikunated URLs are tested for 200 OK. Payload: %{"service_name" => [{"container_port", "url"}, ...], ...}
  # "started" - Called when docker containers are started and haikunated URLs are assigned. Payload: %{"service_name" => [{"container_port", "url"}, ...], ...}
  # "stopping" - Called when docker containers are being stopped. No payload.
  # "stopped" - Called when docker containers are stopped. No payload.
  # "deployment_failed" - Called when deployment fails. Payload: "Error message"

  alias DockupUi.{
    DeploymentStatusUpdateService
  }

  def lambda(deployment, service \\ DeploymentStatusUpdateService) do
    fn
      event, payload ->
        service.run(event, deployment.id, payload)
    end
  end
end
