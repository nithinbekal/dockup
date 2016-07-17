defmodule Dockup.NginxConfigTest do
  use ExUnit.Case, async: true

  test "write_config writes nginx config given ports on containers" do
    defmodule FakeHaikunator do
      def haikunated_url, do: "haikunated_url"
    end

    ip_ports = [
      {"1.2.3.4", ["80", "4000"]},
      {"1.2.3.5", []}
    ]

    Dockup.NginxConfig.write_config("foo", ip_ports, FakeHaikunator)
    {:ok, content} = File.read(Dockup.NginxConfig.config_file("foo"))
    assert content == """
    server {
      listen 80;
      server_name haikunated_url;

      location / {
        proxy_pass http://1.2.3.4:80;
        proxy_set_header Host $host;
      }
    }

    server {
      listen 4000;
      server_name haikunated_url;

      location / {
        proxy_pass http://1.2.3.4:4000;
        proxy_set_header Host $host;
      }
    }
    """

    File.rm!(Path.join(Dockup.Configs.nginx_config_dir, "foo.conf"))
  end

  test "generate nginx config string for proxy-passing ports" do
    urls_proxies =
      [{"3000", "http://fake_host:3000", "shy-surf-3571.127.0.0.1.xip.io"},
       {"3001", "http://fake_host:3001", "long-flower-2811.127.0.0.1.xip.io"},
       {"8080", "http://fake_host2:8080", "crimson-meadow-2.127.0.0.1.xip.io"}]

    nginx_config_content =
      Dockup.NginxConfig.config_proxy_passing_port(urls_proxies)
    assert nginx_config_content == """
    server {
      listen 3000;
      server_name shy-surf-3571.127.0.0.1.xip.io;

      location / {
        proxy_pass http://fake_host:3000;
        proxy_set_header Host $host;
      }
    }

    server {
      listen 3001;
      server_name long-flower-2811.127.0.0.1.xip.io;

      location / {
        proxy_pass http://fake_host:3001;
        proxy_set_header Host $host;
      }
    }

    server {
      listen 8080;
      server_name crimson-meadow-2.127.0.0.1.xip.io;

      location / {
        proxy_pass http://fake_host2:8080;
        proxy_set_header Host $host;
      }
    }
    """
  end
end
