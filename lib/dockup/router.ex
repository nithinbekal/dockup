defmodule Dockup.Router do
  use Plug.Router

  plug :match
  plug :dispatch

  def start_server do
    {port, _} = Application.fetch_env!(:dockup, :port) |> Integer.parse
    {:ok, ip} = Application.fetch_env!(:dockup, :bind) |> String.to_char_list |> :inet.parse_address
    {:ok, _} = Plug.Adapters.Cowboy.http __MODULE__, [], [port: port, ip: ip]
  end

  get "/" do
    send_resp(conn, 200, "Hello Plug!")
  end

  match _ do
    send_resp(conn, 404, "Nothing here")
  end
end
