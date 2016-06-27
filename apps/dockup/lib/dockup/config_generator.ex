defmodule Dockup.ConfigGenerator do
  alias Dockup.DockerComposeConfig

  def generate(:static_site, project_id, docker_compose_config \\ DockerComposeConfig) do
    docker_compose_config.write_config(:static_site, project_id)
  end
end
