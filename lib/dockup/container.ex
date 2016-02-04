require Logger

defmodule Dockup.Container do
  def create_cache_container do
    try do
      container = Dockup.Configs.cache_container
      volume = Dockup.Configs.cache_volume
      case Dockup.Command.run("docker", ["run", "--name", container, "-v", volume, "tianon/true"]) do
        {_, 0} -> Logger.info "Created docker container #{container}"
        x -> Logger.warn "Cannot create docker container #{container}. It may already exist"
      end
    rescue
      RuntimeError -> raise "Command to create cache container failed"
    end
  end
end
