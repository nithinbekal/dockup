require Logger

defmodule Dockup.Container do
  def create_cache_container do
    try do
      container = Dockup.Configs.cache_container
      volume = Dockup.Configs.cache_volume
      case Dockup.Command.run("docker", ["run", "--name", container, "-v", volume, "tianon/true"]) do
        {_, 0} -> Logger.info "Created docker container #{container}"
        _ -> Logger.warn "Cannot create docker container #{container}. It may already exist"
      end
    rescue
      _ -> raise "Command to create cache container failed"
    end
  end

  def run_nginx_container do
    {status, exit_code} = Dockup.Command.run("docker", ["inspect", "--format='{{.State.Running}}'", "nginx"])
    if status == "false" do
      {_output, 0} = Dockup.Command.run("docker", ["start", "nginx"])
    end

    if exit_code == 1 do
      # Sometimes docker pull fails, so we retry -
      # Try 5 times at an interval of 0.5 seconds
      retry 5 in 500 do
        {_output, 0} = Dockup.Command.run("docker", ["run", "--name", "nginx", "-p", "80:80", "-v", "nginx_sites_enabled:/etc/nginx/sites-enabled", "nginx:1.8"])
      end
    end
  end

  def check_docker_version do
    {docker_version, 0} = Dockup.Command.run("docker", ["-v"])
    unless Regex.match?(~r/Docker version 1\.([8-9]|([0-9][0-9]))(.*)+/, docker_version) do
      raise "Docker version should be >= 1.8"
    end

    {docker_compose_version, 0} = Dockup.Command.run("docker-compose", ["-v"])
    unless Regex.match?(~r/docker-compose version.* 1\.([4-9]|([0-9][0-9]))(.*)+/, docker_compose_version) do
      raise "docker-compose version should be >= 1.4"
    end
  end
end
