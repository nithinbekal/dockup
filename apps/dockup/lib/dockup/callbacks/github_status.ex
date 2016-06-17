defmodule Dockup.Callbacks.GithubStatus do
  def deployment_success(repository, branch, urls, callback_url, http_module \\ __MODULE__) do
    body = %{
      state: "success",
      target_url: Poison.encode!(urls),
      description: "Deployed branch #{branch}",
      context: "deployment/dockup"
    }
    http_module.send_request(callback_url, body)
  end

  def deployment_failure(repository, branch, reason, callback_url, http_module \\ __MODULE__) do
    body = %{
      state: "failure",
      description: "Could not deploy branch: #{branch}. Reason: #{reason}",
      context: "deployment/dockup"
    }
    http_module.send_request(callback_url, body)
  end

  def send_request(callback_url, body) do
    HTTPotion.post(callback_url, [body: Poison.encode!(body), headers: ["Content-Type": "application/json"]])
  end
end
