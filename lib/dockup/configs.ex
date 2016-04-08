defmodule Dockup.Configs do
  def port do
    port_str = System.get_env("DOCKUP_PORT") || Application.fetch_env!(:dockup, :port)
    case (port_str |> Integer.parse) do
      {port, _} -> port
      _ -> raise "Invalid port"
    end
  end

  def ip do
    ip_str = System.get_env("DOCKUP_BIND") || Application.fetch_env!(:dockup, :bind)
    case (ip_str |> String.to_char_list |> :inet.parse_address) do
      {:ok, ip} -> ip
      _ -> raise "Invalid ip"
    end
  end

  def workdir do
    System.get_env("DOCKUP_WORKDIR") || Application.fetch_env!(:dockup, :workdir)
    |> ensure_dir_exists
  end

  def cache_container do
    System.get_env("DOCKUP_CACHE_CONTAINER") || Application.fetch_env!(:dockup, :cache_container)
  end

  def cache_volume do
    System.get_env("DOCKUP_CACHE_VOLUME") || Application.fetch_env!(:dockup, :cache_volume)
  end

  def github_webhook_secret do
    System.get_env("DOCKUP_GITHUB_WEBHOOK_SECRET") || Application.fetch_env!(:dockup, :github_webhook_secret)
  end

  def nginx_config_dir do
    System.get_env("DOCKUP_NGINX_CONFIG_DIR") || Application.fetch_env!(:dockup, :nginx_config_dir)
    |> ensure_dir_exists
  end

  def domain do
    System.get_env("DOCKUP_DOMAIN") || Application.fetch_env!(:dockup, :domain)
  end

  def project_index_file do
    System.get_env("DOCKUP_PROJECT_INDEX_FILE") || Application.fetch_env!(:dockup, :project_index_file)
  end

  defp ensure_dir_exists(dir) do
    File.mkdir_p dir
    case File.exists?(dir) do
      true -> dir
      _ -> raise "Invalid workdir"
    end
  end
end
