defmodule DockupUi.Repo.Migrations.CreateDeployment do
  use Ecto.Migration

  def change do
    create table(:deployments) do
      add :git_url, :string
      add :branch, :string
      add :callback_url, :string
      add :status, :string
      add :service_urls, :json

      timestamps
    end

  end
end
