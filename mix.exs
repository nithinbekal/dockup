defmodule Dockup.Mixfile do
  use Mix.Project

  def project do
    [app: :dockup,
     version: "0.0.1",
     elixir: "~> 1.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :cowboy, :plug, :gh_webhook_plug],
     mod: {Dockup, []},
     env: [start_server: true]
   ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:cowboy, "~>1.0.4"},
      {:plug, "~>1.1.0"},
      {:gh_webhook_plug, "~> 0.0.1"},
      {:exrm, "~> 1.0.0-rc7"},
      {:poison, "~>2.1.0"},

      {:mock, "~> 0.1.3", only: :test}
    ]
  end
end
