# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# All configurations are assumed to be strings
config :dockup,
  workdir: "workdir",
  cache_container: "cache",
  cache_volume: "/cache",
  command_module: Dockup.ShellCommand,
  nginx_config_dir: "nginx_config_dir",
  domain: "127.0.0.1.xip.io"
#
# And access this configuration in your application as:
#
#     Application.get_env(:dockup, :key)
#
# Or configure a 3rd-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
import_config "#{Mix.env}.exs"
