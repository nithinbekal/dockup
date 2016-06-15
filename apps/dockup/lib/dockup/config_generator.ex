defmodule Dockup.ConfigGenerator do
  alias Dockup.DockerComposeConfig

  def generate(:static_site, project_id) do
    DockerComposeConfig.write_config(:static_site, project_id)
  end
end
