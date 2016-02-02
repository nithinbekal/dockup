defmodule Dockup.Configs do
  def port do
    case (Application.fetch_env!(:dockup, :port) |> Integer.parse) do
      {port, _} -> port
      _ -> raise "Invalid port."
    end
  end

  def ip do
    case (Application.fetch_env!(:dockup, :bind) |> String.to_char_list |> :inet.parse_address) do
      {:ok, ip} -> ip
      _ -> raise "Invalid ip."
    end
  end

  def workdir do
    dir = Application.fetch_env!(:dockup, :workdir)
    case File.exists?(dir) do
      true -> dir
      _ -> raise "Invalid workdir."
    end
  end
end
