defmodule Dockup.Configs do
  import DefMemo

  defmemo workdir do
    (System.get_env("DOCKUP_WORKDIR") || Application.fetch_env!(:dockup, :workdir))
    |> ensure_dir_exists |> Path.expand
  end

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
    File.mkdir_p dir
    case File.exists?(dir) do
      true -> dir
      _ -> raise "Invalid directory #{dir}"
    end
  end
end
