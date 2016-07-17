use Mix.Config

# In this file, we keep production configuration that
# you likely want to automate and keep it away from
# your version control system.
config :dockup_ui, DockupUi.Endpoint,
  secret_key_base: "tSzvLqPuzu78hCZ7htMXPlJX+qeC18HqfyfwxbSdY2LeVfIJxXlE1/BxnYIEvsH+"

# Configure your database
config :dockup_ui, DockupUi.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "dockup_ui_dev",
  hostname: "db",
  pool_size: 20
