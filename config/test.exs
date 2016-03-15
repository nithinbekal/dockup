use Mix.Config

config :dockup,
  command_module: Dockup.FakeCommand,
  start_server: false

config :logger, backends: []
