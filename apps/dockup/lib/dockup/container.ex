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
    # Do not consider docker container when running tests (for example in CI)
    Mix.env != :test && file.exists?("/.dockerenv")
  end

  def docker_sock_mounted? do
    "/var/run/docker.sock" == volume_host_dir("/var/run/docker.sock")
  end

  def start_containers(project_id, command \\ Dockup.Command) do
    Logger.info "Starting containers of project #{project_id}"
    command.run("docker-compose", ["-p", "#{project_id}", "up", "-d"], Dockup.Project.project_dir(project_id))
  end

  def stop_containers(project_id, command \\ Dockup.Command) do
    Logger.info "Stopping containers of project #{project_id}"
    command.run("docker-compose", ["-p", "#{project_id}", "stop"], Dockup.Project.project_dir(project_id))
  end

  # Returns a list of port mappings for each container in the format:
  # %{"<service name>" => [{"<container_port>", <"host_port">}, ...], ...}
  # This is used to generate an nginx config for the deployment.
  def port_mappings(project_id, container \\ __MODULE__) do
    container.container_ids(project_id)
    |> Enum.reduce(%{}, fn(x, acc) ->
      map = %{container.container_service_name(x) => container.port_mappings_for_container(x)}
      Map.merge(acc, map)
    end)
  end

  def port_mappings_for_container(container_id, command \\ Dockup.Command) do
    {out, 0} = command.run("docker", ["inspect",
      "--format='{{range $p, $conf := .NetworkSettings.Ports}}{{if $conf}}{{$p}}:{{(index $conf 0).HostPort}}\n{{end}}{{end}}'",
      container_id])
    out #  "   80/tcp:3227\n4000/tcp:3228\n   "
    |> String.strip # "80/tcp:3227\n4000/tcp:3228"
    |> String.split("\n") # ["80/tcp:3227", "4000/tcp:3228"]
    |> format_port_mapping # [{"80", "3227"}, {"4000", "3228"}]
  end

  def container_ids(project_id, command \\ Dockup.Command) do
    {out, 0} = command.run("docker-compose", ["-p", "#{project_id}", "ps", "-q"], Dockup.Project.project_dir(project_id))
    out
    |> String.split("\n")
    |> Enum.map(fn(x) -> String.strip(x) end)
  end

  defmemo nginx_config_dir_on_host do
    ensure_volume_host_dir_exists(Dockup.Configs.nginx_config_dir)
  end

  defmemo workdir_on_host do
    ensure_volume_host_dir_exists(Dockup.Configs.workdir)
  end

  def container_service_name(container_id, command \\ Dockup.Command) do
    {out, 0} = command.run("docker", ["inspect",
      "--format='{{index .Config.Labels \"com.docker.compose.service\"}}'", container_id])
    String.strip out
  end

  # If running in a docker container, returns the directory on host,
  # given a mounted volume on the container
  defp volume_host_dir(container_dir) do
    if running_in_docker? do
      container_id = dockup_container_id
      {host_dir, 0} = Dockup.Command.run("docker", ["inspect",
        "--format='{{ range .Mounts }}{{ if eq .Destination \"#{container_dir}\" }}{{ .Source }}{{ end }}{{ end }}'",
        container_id])
      host_dir
    else
      container_dir
    end
  end

  defp ensure_volume_host_dir_exists(dir) do
    host_dir = volume_host_dir(dir) |> String.trim
    if host_dir == "" do
      raise "Cannot find volume mount destination: #{dir}"
    end
    host_dir
  end

  defp dockup_container_id do
    # This is the only dependable way to get the container ID from within a
    # docker container. The problem with using `hostname` is that it can be
    # overridden when running the container.
    # We use :os.cmd because this is a trusted command and we don't want
    # to create a long argument list.
    :os.cmd('cat /proc/self/cgroup | grep -o  -e "docker-.*.scope" | head -n 1 | sed "s/docker-\\(.*\\).scope/\\\\1/"')
    |> to_string
    |> String.trim
  end

  defp format_port_mapping([""]), do: []
  defp format_port_mapping(ports) do
    Enum.map(ports, fn(port) ->
      # port_mapping is of format "80/tcp:3227"
      map = Regex.named_captures(~r/(?<container_port>\d*)\/...:(?<host_port>\d*)/, port) # %{"container_port" => "80", "host_port" => "3227"}
      {map["container_port"], map["host_port"]}
    end)
  end
end
