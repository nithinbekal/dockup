defmodule Dockup.RouterTest do
  use ExUnit.Case
  use Plug.Test

  defp call(conn) do
    conn
    |> put_req_header("content-type", "application/json")
    |> Dockup.Router.call([])
  end

  test "returns 400 when parameters are wrong" do
    :meck.new(Dockup.DeployJob)
    :meck.expect(Dockup.DeployJob, :spawn_process, fn (_args) -> :ok end)

    conn = conn(:post, "/deploy") |> call
    assert conn.status == 400
    assert conn.resp_body == "Bad request"

    refute :meck.called(Dockup.DeployJob, :spawn_process, [:_])
    :meck.validate(Dockup.DeployJob)
    :meck.unload(Dockup.DeployJob)
  end

  test "returns 200 OK when parameters are alright" do
    params = %{"repository" => "https://github.com/code-mancers/project.git", "branch" => "branch", "callback_url" => "http://callback_url"}
    :meck.new(Dockup.DeployJob)
    :meck.expect(Dockup.DeployJob, :spawn_process, fn (_args) -> :ok end)

    conn = conn(:post, "/deploy", params) |> call
    assert conn.status == 200
    assert conn.resp_body == "OK"

    assert :meck.called(Dockup.DeployJob, :spawn_process, [params])
    :meck.validate(Dockup.DeployJob)
    :meck.unload(Dockup.DeployJob)
  end
end
