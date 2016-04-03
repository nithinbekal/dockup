defmodule Dockup.NginxConfig do
  require Logger
  def static_site_config(project_id, url) do
    """
    server {
      listen 80;

      server_name #{url};
      root /dockup/#{project_id};
      index index.html;
    }
    """
  end

  def hash(project_id) do
    :crypto.hash(:sha, project_id) |> Base.encode16
  end

  def config_file(project_id) do
    Path.join(Dockup.Configs.nginx_config_dir, "#{hash(project_id)}.conf")
  end

  def write_config(:static_site, project_id, haikunator \\ Dockup.Haikunator) do
    Logger.info "Writing nginx config for #{project_id}"
    config = static_site_config(project_id, haikunator.haikunated_url)
    File.write(config_file(project_id), config)
  end
end
