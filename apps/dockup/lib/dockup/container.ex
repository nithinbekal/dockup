defmodule Dockup.Container do
  require Logger
  import Dockup.Retry
  import DefMemo

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

  def run_nginx_container(command \\ Dockup.Command, container \\ __MODULE__) do
    File.write!("#{Dockup.Configs.nginx_config_dir}/default.conf", Dockup.NginxConfig.default_config)
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
          "-v", "#{container.nginx_config_dir_on_host}:/etc/nginx/conf.d",
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

  def running_in_docker?(file \\ File) do
    file.exists? "/.dockerenv"
  end

  def ensure_docker_sock_mounted do
    "/var/run/docker.sock" = volume_host_dir("/var/run/docker.sock")
  end

  def start_containers(project_id, command \\ Dockup.Command) do
    Logger.info "Starting containers of project #{project_id}"
    command.run("docker-compose", ["-p", "#{project_id}", "up", "-d"], Dockup.Project.project_dir(project_id))
  end

  def stop_containers(project_id, command \\ Dockup.Command) do
    Logger.info "Stopping containers of project #{project_id}"
    command.run("docker-compose", ["-p", "#{project_id}", "stop"], Dockup.Project.project_dir(project_id))
  end

  def project_ports(project_id, container \\ __MODULE__) do
    container.container_ids(project_id)
    |> Enum.map(fn(x) -> {container.container_ip(x), container.container_ports(x)} end)
  end

  def container_ids(project_id, command \\ Dockup.Command) do
    {out, 0} = command.run("docker-compose", ["-p", "#{project_id}", "ps", "-q"], Dockup.Project.project_dir(project_id))
    out
    |> String.split("\n")
    |> Enum.map(fn(x) -> String.strip(x) end)
  end

  def container_ports(container_id, command \\ Dockup.Command) do
    {out, 0} = command.run("docker", ["inspect",
      "--format='{{range $key, $val := .NetworkSettings.Ports}}{{$key}}\n{{end}}'",
      container_id])
    out #  "   80/tcp\n4000/tcp\n   "
    |> String.strip # "80/tcp\n4000/tcp"
    |> String.split("\n") # ["80/tcp", "4000/tcp"]
    |> Enum.map(fn(x) -> String.split(x, "/") |> List.first end) # ["80", "4000"]
    |> Enum.filter(fn(x) -> String.length(x) > 0 end)
  end

  def container_ip(container_id, command \\ Dockup.Command) do
    {out, 0} = command.run("docker", ["inspect",
      "--format='{{.NetworkSettings.IPAddress}}'", container_id])
    String.strip out
  end

  defmemo nginx_config_dir_on_host do
    volume_host_dir(Dockup.Configs.nginx_config_dir)
  end

  defmemo workdir_on_host do
    volume_host_dir(Dockup.Configs.workdir)
  end

  # If running in a docker container, returns the directory on host,
  # given a mounted volume on the container
  defp volume_host_dir(container_dir, command \\ Dockup.Command) do
    if running_in_docker? do
      {container_id, 0} = command.run("hostname", [])
      {host_dir, 0} = command.run("docker", ["inspect",
        "--format='{{ range .Mounts }}{{ if eq .Destination \"#{container_dir}\" }}{{ .Source }}{{ end }}{{ end }}'",
        container_id])
      host_dir
    else
      container_dir
    end
  end
end
