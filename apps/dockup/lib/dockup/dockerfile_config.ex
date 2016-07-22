defmodule Dockup.DockerfileConfig do
  require Logger

  def write_config(type, project_id) do
    Logger.info "Writing a '#{type}' Dockerfile into project #{project_id}"
    config = config(type)
    File.write!(config_file(project_id), config)
  end

  defp config(:jekyll_site) do
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

  defp config_file(project_id) do
    Path.join(Dockup.Project.project_dir(project_id), "Dockerfile")
  end
end
