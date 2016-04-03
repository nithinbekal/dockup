use Mix.Config

config :dockup,
  command_module: Dockup.FakeCommand,
  workdir: (System.tmp_dir <> "/dockup_test"),
  start_server: false

config :logger, backends: []
