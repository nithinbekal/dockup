# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :dockup_ui, DockupUi.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "n3+zKFQryan438UU2PO1Ypr97ty+a/xjAevgs9i5UtyR5In1sU1CaSes5Zi2jsSv",
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: DockupUi.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :dockup_ui, OAuth.GitHub,
  client_id: System.get_env("GITHUB_CLIENT_ID"),
  client_secret: System.get_env("GITHUB_CLIENT_SECRET"),
  redirect_uri: System.get_env("GITHUB_REDIRECT_URI")

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

# Configure phoenix generators
config :phoenix, :generators,
  migration: true,
  binary_id: false

config :dockup_ui, ecto_repos: [DockupUi.Repo]
