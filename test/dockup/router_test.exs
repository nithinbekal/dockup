defmodule Dockup.RouterTest do
  use ExUnit.Case
  use Plug.Test
  import Mock

  defp call(conn) do
    conn
    |> put_req_header("content-type", "application/json")
    |> Dockup.Router.call([])
  end

  test "returns 400 when parameters are wrong" do
    with_mock DeployJob, [spawn_process: fn(_arg) -> :ok end] do
      conn = conn(:post, "/deploy") |> call
      refute called DeployJob.spawn_process(:_)
      assert conn.status == 400
      assert conn.resp_body == "Bad request"
    end
  end

  test "returns 200 OK when parameters are alright" do
    params = %{"repository" => "https://github.com/code-mancers/project.git", "branch" => "branch", "callback_url" => "http://callback_url"}
    with_mock DeployJob, [spawn_process: fn(_arg) -> :ok end] do
      conn = conn(:post, "/deploy", params) |> call
      assert called DeployJob.spawn_process(params)
      assert conn.status == 200
      assert conn.resp_body == "OK"
    end
  end
end
