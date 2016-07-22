defmodule Dockup.DockerComposeConfigTest do
  use ExUnit.Case, async: true

  test "write_config for static_site writes docker-compose.yml with an nginx service" do
    File.mkdir_p! Dockup.Project.project_dir("foo")
    Dockup.DockerComposeConfig.write_config(:static_site, "foo")
    {:ok, content} = File.read(Path.join(Dockup.Project.project_dir("foo"), "docker-compose.yml"))
    assert content ==
      """
      site:
        image: nginx
        volumes:
          - #{Dockup.Project.project_dir_on_host("foo")}:/usr/share/nginx/html
        ports:
          - 80
      """
  end

  test "write_config for jekyll_site writes docker-compose.yml that exposes port 4000" do
    File.mkdir_p! Dockup.Project.project_dir("foo")
    Dockup.DockerComposeConfig.write_config(:jekyll_site, "foo")
    {:ok, content} = File.read(Path.join(Dockup.Project.project_dir("foo"), "docker-compose.yml"))
    assert content ==
      """
      site:
        image: .
        ports:
          - 4000
      """
  end
end
