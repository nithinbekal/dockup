defmodule Dockup.Callbacks.WebhookTest do
  use ExUnit.Case, async: true

  defmodule FakeHttp do
    def send_request(callback_url, body) do
      send self, {callback_url, body}
    end
  end
  test "deployment_success sends an http request to callback_url with a list of urls" do
    repo = "fake_repo"
    branch = "fake_branch"
    urls = %{app1: %{"3000": "fake_url"}}
    callback_url = "fake_callback_url"
    Dockup.Callbacks.Webhook.deployment_success(repo, branch, urls, callback_url, FakeHttp)
    receive do
      {received_callback_url, body} ->
        assert received_callback_url == callback_url
        assert body[:status] == "deployment_success"
        assert body[:urls] == "{\"app1\":{\"3000\":\"fake_url\"}}"
    end
  end

  test "deployment_failure sends an http request to callback_url with the reason for failure" do
    repo = "fake_repo"
    branch = "fake_branch"
    reason = "fake_reason"
    callback_url = "fake_callback_url"
    Dockup.Callbacks.Webhook.deployment_failure(repo, branch, reason, callback_url, FakeHttp)
    receive do
      {received_callback_url, body} ->
        assert received_callback_url == callback_url
        assert body[:status] == "deployment_failure"
        assert body[:reason] == reason
    end
  end
end

