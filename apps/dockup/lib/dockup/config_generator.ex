defmodule Dockup.ConfigGenerator do
  alias Dockup.{
    DockerComposeConfig,
    DockerfileConfig
  }

  def generate(type, project_id, dockerfile_config \\ DockerfileConfig, docker_compose_config \\ DockerComposeConfig)

  def generate(:static_site, project_id, _, docker_compose_config) do
    docker_compose_config.write_config(:static_site, project_id)
  end

  def generate(:jekyll_site, project_id, dockerfile_config, docker_compose_config) do
    dockerfile_config.write_config(:jekyll_site, project_id)
    docker_compose_config.write_config(:jekyll_site, project_id)
  end
end
