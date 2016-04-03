defmodule Dockup.Container do
  require Logger
  import Dockup.Retry

  def create_cache_container(command \\ Dockup.Command) do
    try do
      container = Dockup.Configs.cache_container
      volume = Dockup.Configs.cache_volume
      case command.run("docker", ["run", "--name", container, "-v", volume, "tianon/true"]) do
        {_, 0} -> Logger.info "Created docker container #{container}"
        _ -> Logger.warn "Cannot create docker container #{container}. It may already exist"
      end
    rescue
      _ -> raise "Command to create cache container failed"
    end
  end

  def run_nginx_container(command \\ Dockup.Command) do
    {status, exit_code} = command.run("docker", ["inspect", "--format='{{.State.Running}}'", "nginx"])
    if status == "false" do
      Logger.info "Nginx container seems to be down. Trying to start."
      {_output, 0} = command.run("docker", ["start", "nginx"])
      Logger.info "Nginx started"
    end

    if exit_code == 1 do
      Logger.info "Nginx container not found."
      # Sometimes docker pull fails, so we retry -
      # Try 5 times at an interval of 0.5 seconds
      retry 5 in 500 do
        Logger.info "Trying to pull nginx image"
        {_output, 0} = command.run("docker", ["run", "--name", "nginx",
          "-d", "-p", "80:80",
          "-v", "#{Dockup.Configs.nginx_config_dir}:/etc/nginx/sites-enabled",
          "-v", "#{Dockup.Configs.workdir}:/dockup:ro",
          "nginx:1.8"])
      end
      Logger.info "Nginx pulled and started"
    end
  end

  def reload_nginx(command \\ Dockup.Command) do
    Logger.info "Reloading nxinx config"
    {_out, 0} = command.run("docker", ["kill", "-s", "HUP", "nginx"])
  end

  def check_docker_version(command \\ Dockup.Command) do
    {docker_version, 0} = command.run("docker", ["-v"])
    unless Regex.match?(~r/Docker version 1\.([8-9]|([0-9][0-9]))(.*)+/, docker_version) do
      raise "Docker version should be >= 1.8"
    end

    {docker_compose_version, 0} = command.run("docker-compose", ["-v"])
    unless Regex.match?(~r/docker-compose version.* 1\.([4-9]|([0-9][0-9]))(.*)+/, docker_compose_version) do
      raise "docker-compose version should be >= 1.4"
    end
  end
end
