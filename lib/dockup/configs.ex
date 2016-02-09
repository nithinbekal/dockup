defmodule Dockup.Configs do
  def port do
    case (Application.fetch_env!(:dockup, :port) |> Integer.parse) do
      {port, _} -> port
      _ -> raise "Invalid port"
    end
  end

  def ip do
    case (Application.fetch_env!(:dockup, :bind) |> String.to_char_list |> :inet.parse_address) do
      {:ok, ip} -> ip
      _ -> raise "Invalid ip"
    end
  end

  def workdir do
    dir = Application.fetch_env!(:dockup, :workdir)
    case File.exists?(dir) do
      true -> dir
      _ -> raise "Invalid workdir"
    end
  end

  def cache_container do
    Application.fetch_env!(:dockup, :cache_container)
  end

  def cache_volume do
    Application.fetch_env!(:dockup, :cache_volume)
  end

  def github_webhook_secret do
    Application.fetch_env!(:dockup, :github_webhook_secret)
  end
end
