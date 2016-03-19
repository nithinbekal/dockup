defmodule Dockup.Container do
  require Logger
  import Dockup.Retry

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
      Logger.info "Nginx container seems to be down. Trying to start."
      {_output, 0} = Dockup.Command.run("docker", ["start", "nginx"])
      Logger.info "Nginx started"
    end

    if exit_code == 1 do
      Logger.info "Nginx container not found."
      # Sometimes docker pull fails, so we retry -
      # Try 5 times at an interval of 0.5 seconds
      retry 5 in 500 do
        Logger.info "Trying to pull nginx image"
        {_output, 0} = Dockup.Command.run("docker", ["run", "--name", "nginx", "-d", "-p", "80:80", "-v", "nginx_sites_enabled:/etc/nginx/sites-enabled", "nginx:1.8"])
      end
      Logger.info "Nginx pulled and started"
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
