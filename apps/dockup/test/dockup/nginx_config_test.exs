defmodule Dockup.NginxConfigTest do
  use ExUnit.Case, async: true

  test "write_config for static site writes an nginx config for static sites" do
    defmodule FakeHaikunator do
      def haikunated_url, do: "haikunated_url"
    end

    Dockup.NginxConfig.write_config(:static_site, "hello/world", FakeHaikunator)
    {:ok, content} = File.read(Dockup.NginxConfig.config_file("hello/world"))
    assert content == """
    server {
      listen 80;

      server_name haikunated_url;
      root /dockup/hello/world;
      index index.html;
    }
    """
    File.rm_rf Dockup.Configs.nginx_config_dir
  end
end
