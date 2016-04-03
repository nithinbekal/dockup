defmodule Dockup.NginxConfigTest do
  use ExUnit.Case

  test "write_config for static site writes an nginx config for static sites" do
    defmodule FakeHaikunator do
      def haikunated_url, do: "haikunated_url"
    end

    Dockup.NginxConfig.write_config(:static_site, "hello/world", FakeHaikunator)
    {:ok, content} = File.read(Dockup.NginxConfig.config_file("hello/world"))
    assert content == """
    server {
      listen 80;

      root /dockup/hello/world;
      index index.html;

      server_name haikunated_url;

      location / {
        try_files $uri $uri/ =404;
      }
    }
    """
    File.rm_rf Dockup.Configs.nginx_config_dir
  end
end
