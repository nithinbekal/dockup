defmodule Dockup.Callbacks.GithubStatusTest do
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
    Dockup.Callbacks.GithubStatus.deployment_success(repo, branch, urls, callback_url, FakeHttp)
    receive do
      {received_callback_url, body} ->
        assert received_callback_url == callback_url
        assert body[:state] == "success"
        assert body[:target_url] == "{\"app1\":{\"3000\":\"fake_url\"}}"
        assert body[:description] == "Deployed branch fake_branch"
        assert body[:context] == "deployment/dockup"
    end
  end

  test "deployment_failure sends an http request to callback_url with the reason for failure" do
    repo = "fake_repo"
    branch = "fake_branch"
    reason = "fake_reason"
    callback_url = "fake_callback_url"
    Dockup.Callbacks.GithubStatus.deployment_failure(repo, branch, reason, callback_url, FakeHttp)
    receive do
      {received_callback_url, body} ->
        assert received_callback_url == callback_url
        assert body[:state] == "failure"
        assert body[:description] == "Could not deploy branch: #{branch}. Reason: fake_reason"
        assert body[:context] == "deployment/dockup"
    end
  end
end

