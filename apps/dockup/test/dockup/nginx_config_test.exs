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

  test "generate nginx config string for proxy-passing ports" do
    urls_proxies =
      [{"http://fake_host:3000", "shy-surf-3571.127.0.0.1.xip.io"},
       {"http://fake_host:3001", "long-flower-2811.127.0.0.1.xip.io"},
       {"http://fake_host2:8080", "crimson-meadow-2.127.0.0.1.xip.io"}]

    nginx_config_content =
      Dockup.NginxConfig.config_proxy_passing_port(urls_proxies)
    assert nginx_config_content == """
    server{
      listen 80;
      server_name shy-surf-3571.127.0.0.1.xip.io;

      location / {
        proxy_pass http://fake_host:3000;
        proxy_set_header Host $host;
      }
    }
    server{
      listen 80;
      server_name long-flower-2811.127.0.0.1.xip.io;

      location / {
        proxy_pass http://fake_host:3001;
        proxy_set_header Host $host;
      }
    }
    server{
      listen 80;
      server_name crimson-meadow-2.127.0.0.1.xip.io;

      location / {
        proxy_pass http://fake_host2:8080;
        proxy_set_header Host $host;
      }
    }
    """
  end
end
