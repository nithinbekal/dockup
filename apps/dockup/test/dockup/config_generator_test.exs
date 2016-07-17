defmodule Dockup.ConfigGeneratorTest do
  use ExUnit.Case, async: true

  test "generate for static_site writes a docker-compose.yml" do
    defmodule FakeDockerComposeConfig do
      def write_config(:static_site, "foo") do
        send self, :docker_compose_generated
      end
    end

    Dockup.ConfigGenerator.generate(:static_site, "foo", FakeDockerComposeConfig)
    assert_received :docker_compose_generated
  end
end

