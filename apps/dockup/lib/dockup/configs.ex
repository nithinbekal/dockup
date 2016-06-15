defmodule Dockup.Configs do
  import DefMemo

  defmemo workdir do
    (System.get_env("DOCKUP_WORKDIR") || Application.fetch_env!(:dockup, :workdir))
    |> ensure_dir_exists
  end

  defmemo nginx_config_dir do
    (System.get_env("DOCKUP_NGINX_CONFIG_DIR") || Application.fetch_env!(:dockup, :nginx_config_dir))
    |> ensure_dir_exists
  end

  defmemo cache_container do
    System.get_env("DOCKUP_CACHE_CONTAINER") || Application.fetch_env!(:dockup, :cache_container)
  end

  defmemo cache_volume do
    System.get_env("DOCKUP_CACHE_VOLUME") || Application.fetch_env!(:dockup, :cache_volume)
  end

  #def github_webhook_secret do
    #System.get_env("DOCKUP_GITHUB_WEBHOOK_SECRET") || Application.fetch_env!(:dockup, :github_webhook_secret)
  #end

  #def workdir_on_host do
    #System.get_env("DOCKUP_WORKDIR") || raise "Environment variable DOCKUP_WORKDIR cannot be empty"
  #end

  #def nginx_config_dir_on_host do
    #System.get_env("DOCKUP_NGINX_CONFIG_DIR") || raise "Environment variable DOCKUP_NGINX_CONFIG_DIR cannot be empty"
  #end

  defmemo domain do
    System.get_env("DOCKUP_DOMAIN") || Application.fetch_env!(:dockup, :domain)
  end

  defp ensure_dir_exists(dir) do
    File.mkdir_p dir
    case File.exists?(dir) do
      true -> dir
      _ -> raise "Invalid workdir"
    end
  end
end
