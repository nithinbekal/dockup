defmodule DockupUi.Factory do
  use ExMachina.Ecto, repo: DockupUi.Repo

  def deployment_factory do
    %DockupUi.Deployment{
      git_url: "https://github.com/code-mancers/dockup.git",
      branch: "master",
      callback_url: "http://example.com/callback",
      status: "deploying"
    }
  end
end
