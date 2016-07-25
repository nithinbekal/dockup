defmodule Dockup.NginxConfigTest do
  use ExUnit.Case, async: true

  test "write_config writes nginx config given port mappings on containers" do
    defmodule FakeHaikunator do
      def haikunated_url, do: "haikunated_url"
    end

    service_port_mappings = %{
      "nginx" => {"fake_ip1", [{"80", "3229"}]},
      "no_ports" => {"fake_ip2", []},
      "web" => {"fake_ip3", [{"80", "3227"}, {"4000", "3228"}]}
    }

    port_urls = Dockup.NginxConfig.write_config("foo", service_port_mappings, FakeHaikunator)
    {:ok, content} = File.read(Dockup.NginxConfig.config_file("foo"))
    assert content == """
    server {
      listen 80;
      server_name haikunated_url;

      location / {
        proxy_pass http://fake_ip1:80;
        proxy_set_header Host $host;
      }
    }

    server {
      listen 80;
      server_name haikunated_url;

      location / {
        proxy_pass http://fake_ip3:80;
        proxy_set_header Host $host;
      }
    }

    server {
      listen 80;
      server_name haikunated_url;

      location / {
        proxy_pass http://fake_ip3:4000;
        proxy_set_header Host $host;
      }
    }
    """

    expected_return_value = %{
      "web" => [%{"port" => "80", "url" => "haikunated_url"}, %{"port" => "4000", "url" => "haikunated_url"}],
      "nginx" => [%{"port" => "80", "url" => "haikunated_url"}]
    }
    assert port_urls == expected_return_value

    File.rm!(Path.join(Dockup.Configs.nginx_config_dir, "foo.conf"))
  end

  test "generate nginx config string for proxy-passing ports" do
    urls_proxies =
      [{"fake_ip1", "3000", "shy-surf-3571.127.0.0.1.xip.io"},
       {"fake_ip2", "3001", "long-flower-2811.127.0.0.1.xip.io"},
       {"fake_ip3", "8080", "crimson-meadow-2.127.0.0.1.xip.io"}]

    nginx_config_content =
      Dockup.NginxConfig.config_proxy_passing_port(urls_proxies)
    assert nginx_config_content == """
    server {
      listen 80;
      server_name shy-surf-3571.127.0.0.1.xip.io;

      location / {
        proxy_pass http://fake_ip1:3000;
        proxy_set_header Host $host;
      }
    }

    server {
      listen 80;
      server_name long-flower-2811.127.0.0.1.xip.io;

      location / {
        proxy_pass http://fake_ip2:3001;
        proxy_set_header Host $host;
      }
    }

    server {
      listen 80;
      server_name crimson-meadow-2.127.0.0.1.xip.io;

      location / {
        proxy_pass http://fake_ip3:8080;
        proxy_set_header Host $host;
      }
    }
    """
  end
end
