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
    dir = System.get_env("DOCKUP_WORKDIR") || Application.fetch_env!(:dockup, :workdir)
    File.mkdir_p dir
    case File.exists?(dir) do
      true -> dir
      _ -> raise "Invalid workdir"
    end
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
end
