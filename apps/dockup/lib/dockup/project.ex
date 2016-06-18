defmodule Dockup.Project do
  require Logger
  import Dockup.Retry

  def clone_repository(project_id, repository, branch, command \\ Dockup.Command) do
    project_dir = project_dir(project_id)
    Logger.info "Cloning #{repository} : #{branch} into #{project_dir}"
    File.rm_rf(project_dir)
    File.mkdir_p!(project_dir)
    case command.run("git", ["clone", "--branch=#{branch}", "--depth=1", repository, project_dir]) do
      {_out, 0} -> :ok
      {out, _} -> raise out
    end
  rescue
    error ->
      raise DockupException, "Cannot clone #{branch} of #{repository}. Error: #{error.message}"
  end

  def project_dir(project_id) do
    "#{Dockup.Configs.workdir}/#{project_id}"
  end

  def project_dir_on_host(project_id) do
    "#{Dockup.Container.workdir_on_host}/#{project_id}"
  end

  def project_type(project_id) do
    project_dir = project_dir(project_id)
    cond do
      static_site?(project_dir) -> :static_site
      # Rails etc can be auto detected in the future
      true -> :unknown
    end
  end

  # Waits until the urls all return expected HTTP status.
  # Currently, assuming that URLs are for static sites
  # and they return 200.
  def wait_till_up(urls, http \\ __MODULE__, interval \\ 3000) do
    urls
    |> Enum.map(fn {_port, url} -> {url, 200}  end)
    |> Enum.each(fn {url, response} ->
      # Retry 10 times in an interval of 3 seconds
      retry 10 in interval do
        ^response = http.get_status(url)
      end
    end)
    Logger.info "URLs #{inspect urls} seem up because they respond with 200."
  end

  def start(project_id, container \\ Dockup.Container, nginx_config \\ Dockup.NginxConfig) do
    container.start_containers(project_id)
    ips_ports = container.project_ports(project_id)
    nginx_config.write_config(project_id, ips_ports)
    #container.reload_nginx
  end

  def get_status(url) do
    HTTPotion.get(url).status_code
  end

  defp static_site?(project_dir) do
    File.exists? "#{project_dir}/index.html"
  end
end
