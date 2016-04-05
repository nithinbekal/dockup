defmodule Dockup.RouterTest do
  use ExUnit.Case
  use Plug.Test

  defp call(conn) do
    conn
    |> put_req_header("content-type", "application/json")
    |> Dockup.Router.call([])
  end

  test "returns 400 when parameters are wrong" do
    defmodule UnusedFakeDeployJob do
      def spawn_process(_args) do
        raise "This function should not be called"
      end
    end

    conn = conn(:post, "/deploy")
    |> assign(:deploy_job, FakeDeployJob)
    |> call
    assert conn.status == 400
    assert conn.resp_body == "Bad request"
  end

  test "returns 200 OK when parameters are alright" do
    repository = "https://github.com/code-mancers/project.git"
    branch = "branch"
    callback_url = "http://callbackrl"
    params = %{"repository" => repository, "branch" => branch, "callback_url" => callback_url}
    defmodule FakeDeployJob do
      def spawn_process(args) do
        send self, args
      end
    end

    conn = conn(:post, "/deploy", params)
    |> assign(:deploy_job, FakeDeployJob)
    |> call

    receive do
      args -> assert args == {repository, branch, {Dockup.Callbacks.Webhook, callback_url}}
    end
    assert conn.status == 200
    assert conn.resp_body == "OK"
  end
end
