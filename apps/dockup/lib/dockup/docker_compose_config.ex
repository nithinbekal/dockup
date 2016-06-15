defmodule Dockup.DockerComposeConfig do
  require Logger

  def write_config(:static_site, project_id) do
    Logger.info "Writing a 'static site' docker-compose.yml into project #{project_id}"
    config = static_site_config(Dockup.Container.workdir_on_host)
    File.write!(config_file(project_id), config)
  end

  defp static_site_config(directory_on_host) do
    """
    site:
      image: nginx
      volumes:
        - #{directory_on_host}:/usr/share/nginx/html
      ports:
        - 80
    """
  end

  defp config_file(project_id) do
    Path.join(Dockup.Project.project_dir(project_id), "docker-compose.yml")
  end
end
