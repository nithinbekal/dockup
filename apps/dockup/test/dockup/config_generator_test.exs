defmodule Dockup.ConfigGeneratorTest do
  use ExUnit.Case, async: true

  test "generate for static_site writes a docker-compose.yml" do
    defmodule FakeStaticSiteDockerComposeConfig do
      def write_config(:static_site, "foo") do
        send self, :docker_compose_generated
      end
    end

    Dockup.ConfigGenerator.generate(:static_site, "foo", nil, FakeStaticSiteDockerComposeConfig)
    assert_received :docker_compose_generated
  end

  test "generate for jekyll_site writes Dockerfile and docker-compose.yml" do
    defmodule FakeDockerfileConfig do
      def write_config(:jekyll_site, "foo") do
        send self, :dockerfile_generated
      end
    end

    defmodule FakeJekyllSiteDockerComposeConfig do
      def write_config(:jekyll_site, "foo") do
        send self, :docker_compose_generated
      end
    end

    Dockup.ConfigGenerator.generate(:jekyll_site, "foo", FakeDockerfileConfig, FakeJekyllSiteDockerComposeConfig)
    assert_received :dockerfile_generated
    assert_received :docker_compose_generated
  end
end

