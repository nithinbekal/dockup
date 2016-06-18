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

  def default_config do
    """
    server {
      listen 80 default_server;
      listen [::]:80 default_server ipv6only=on;
      listen 443 default_server ssl;
      listen [::]:443 default_server ssl ipv6only=on;

      return 404;

      server_name _ ;
    }
    """
  end

  # accepts a urls_proxies tuple.
  # e.g.
  # [{"http://fake_host:3000", "shy-surf-3571.127.0.0.1.xip.io"}
  # {"http://fake_host:3001", "long-flower-2811.127.0.0.1.xip.io"}
  # {"http://fake_host2:8080", "crimson-meadow-2.127.0.0.1.xip.io"}]
  def config_proxy_passing_port(urls_proxies) do
    Enum.map(urls_proxies, &proxy_passing_port&1) |> Enum.join
  end

  def hash(project_id) do
    :crypto.hash(:sha, project_id) |> Base.encode16
  end

  def config_file(project_id) do
    Path.join(Dockup.Configs.nginx_config_dir, "#{hash(project_id)}.conf")
  end

  def write_config(:static_site, project_id, haikunator \\ Dockup.Haikunator) do
    url = haikunator.haikunated_url
    Logger.info "Writing nginx config to serve #{project_id} at http://#{url}"
    config = static_site_config(project_id, url)
    File.write(config_file(project_id), config)
    %{"80" => url}
  end

  def proxy_passing_port({proxy, url}) do
    """
    server{
    listen 80;
      server_name #{url};

      location / {
         proxy_pass #{proxy};
         proxy_set_header Host $host;
      }
    }
    """
  end
end
