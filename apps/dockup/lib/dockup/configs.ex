defmodule Dockup.Configs do
  require Logger
  import DefMemo

  @lint {Credo.Check.Refactor.PipeChainStart, false}
  defmemo workdir do
    (System.get_env("DOCKUP_WORKDIR") || Application.fetch_env!(:dockup, :workdir))
    |> ensure_dir_exists |> Path.expand
  end

  @lint {Credo.Check.Refactor.PipeChainStart, false}
  defmemo nginx_config_dir do
    (System.get_env("DOCKUP_NGINX_CONFIG_DIR") || Application.fetch_env!(:dockup, :nginx_config_dir))
    |> ensure_dir_exists |> Path.expand
  end

  defmemo cache_container do
    System.get_env("DOCKUP_CACHE_CONTAINER") || Application.fetch_env!(:dockup, :cache_container)
  end

  defmemo cache_volume do
    System.get_env("DOCKUP_CACHE_VOLUME") || Application.fetch_env!(:dockup, :cache_volume)
  end

  defmemo domain do
    System.get_env("DOCKUP_DOMAIN") || Application.fetch_env!(:dockup, :domain)
  end

  defp ensure_dir_exists(dir) do
    unless File.exists?(dir) do
      Logger.info "Creating missing directory: #{dir}"
      File.mkdir_p! dir
    end
    dir
  end
end
