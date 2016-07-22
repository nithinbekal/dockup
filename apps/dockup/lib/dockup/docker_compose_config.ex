defmodule Dockup.DockerComposeConfig do
  require Logger

  def write_config(type, project_id) do
    Logger.info "Writing a '#{type}' docker-compose.yml into project #{project_id}"
    config = config(type, project_id)
    File.write!(config_file(project_id), config)
  end

  defp config(:static_site, project_id) do
    directory_on_host = Dockup.Project.project_dir_on_host(project_id)
    """
    site:
      image: nginx
      volumes:
        - #{directory_on_host}:/usr/share/nginx/html
      ports:
        - 80
    """
  end

  defp config(:jekyll_site, _project_id) do
    """
    site:
      build: .
      ports:
        - 4000
    """
  end

  defp config_file(project_id) do
    Path.join(Dockup.Project.project_dir(project_id), "docker-compose.yml")
  end
end
