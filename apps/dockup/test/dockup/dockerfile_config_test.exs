defmodule Dockup.DockerfileConfigTest do
  use ExUnit.Case, async: true

  test "write_config for jekyll_site" do
    File.mkdir_p! Dockup.Project.project_dir("foo")
    Dockup.DockerfileConfig.write_config(:jekyll_site, "foo")
    {:ok, content} = File.read(Path.join(Dockup.Project.project_dir("foo"), "Dockerfile"))
    assert content ==
      """
      FROM ubuntu

      RUN apt-get update
      RUN apt-get -y install build-essential zlib1g-dev ruby-dev ruby nodejs
      RUN gem install github-pages

      RUN mkdir -p /site
      WORKDIR /site
      COPY . ./

      EXPOSE 4000

      ENTRYPOINT ["jekyll"]
      CMD ["serve"]
      """
  end
end
