defmodule DockupUi.DeployService do
  alias DockupUi.{
    Deployment,
    Repo
  }

  def run(deployment_params, deploy_job \\ Dockup.DeployJob) do
    with \
      changeset <- Deployment.changeset(%Deployment{status: "deploying"}, deployment_params),
      {:ok, deployment} <- Repo.insert(changeset),
      :ok <- deploy_project(deploy_job, deployment)
    do
      {:ok, deployment}
    end
  end

  defp deploy_project(deploy_job, deployment) do
    deployment
    |> prepare_deployment_params
    |> deploy_job.spawn_process
    :ok
  end

  defp prepare_deployment_params(%{id: id, git_url: repo, branch: branch, callback_url: callback_url}) do
    {id, repo, branch, {Dockup.Callbacks.Webhook, callback_url}}
  end
end
