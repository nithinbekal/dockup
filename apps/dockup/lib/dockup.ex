defmodule Dockup do
  def run_preflight_checks do
    # Check if workdir exists
    Dockup.Configs.workdir

    # Check if nginx_config_dir exists inside dockup container
    Dockup.Configs.nginx_config_dir

    # We need access to docker socket to manage docker containers on the host
    if Dockup.Container.running_in_docker? do
      true = Dockup.Container.docker_sock_mounted?

      # Ensure we know the workdir on host
      Dockup.Container.workdir_on_host
      # Ensure we know the nginx config dir on host
      Dockup.Container.nginx_config_dir_on_host
    end

    # Ensure "DOCKUP_DOMAIN" config is set
    Dockup.Configs.domain

    # Check if docker and docker-compose versions are ok
    Dockup.Container.check_docker_version

    # Make sure cache container exists
    Dockup.Container.create_cache_container

    # Make sure logio container is running.
    # This container will be used to tail logs
    # of docker-compose projects
    Dockup.Container.run_logio_container

    # Make sure nginx container is running
    Dockup.Container.run_nginx_container
  end
end
