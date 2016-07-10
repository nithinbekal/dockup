defmodule Dockup.Callbacks.Null do
  require Logger

  def deployment_success(repository, branch, urls, _args) do
    Logger.info "Deployed branch #{branch} of repository #{repository}. Exposed URLs : #{inspect urls}"
  end

  def deployment_failure(repository, branch, reason, _args) do
    Logger.info "Failed to deploy branch #{branch} of repository #{repository}. Reason: #{reason}"
  end
end
