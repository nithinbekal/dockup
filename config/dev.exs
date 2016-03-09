use Mix.Config

config :dockup,
  #port: System.get_env("DOCKUP_PORT") || 8000,
  #bind: System.get_env("DOCKUP_BIND") || '0.0.0.0'
  command_module: Dockup.FakeCommand
