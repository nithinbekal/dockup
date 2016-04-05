defmodule Dockup.Callbacks.Webhook do
  def deployment_success(repository, branch, urls, callback_url, http_module \\ __MODULE__) do
    body = %{
      urls: Poison.encode!(urls),
      status: "deployment_success",
      repository: repository,
      branch: branch
    }
    http_module.send_request(callback_url, body)
  end

  def deployment_failure(repository, branch, reason, callback_url, http_module \\ __MODULE__) do
    body = %{
      reason: reason,
      status: "deployment_failure",
      repository: repository,
      branch: branch
    }
    http_module.send_request(callback_url, body)
  end

  def send_request(callback_url, body) do
    HTTPotion.post(callback_url, [body: Poison.encode!(body), headers: ["Content-Type": "application/json"]])
  end
end
