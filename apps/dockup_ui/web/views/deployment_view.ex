defmodule DockupUi.DeploymentView do
  use DockupUi.Web, :view

  def render("index.json", %{deployments: deployments}) do
    %{data: render_many(deployments, DockupUi.DeploymentView, "deployment.json")}
  end

  def render("show.json", %{deployment: deployment}) do
    %{data: render_one(deployment, DockupUi.DeploymentView, "deployment.json")}
  end

  def render("deployment.json", %{deployment: deployment}) do
    %{
      id: deployment.id,
      git_url: deployment.git_url,
      branch: deployment.branch,
      status: deployment.status
    }
  end
end
