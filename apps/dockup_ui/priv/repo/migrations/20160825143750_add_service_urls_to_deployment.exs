defmodule DockupUi.Repo.Migrations.AddServiceUrlsToDeployment do
  use Ecto.Migration

  def change do
    alter table(:deployments) do
      add :service_urls, :json
    end
  end
end
