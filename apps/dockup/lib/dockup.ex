defmodule Dockup do
  def run_preflight_checks do
    # Check if workdir exists
    Dockup.Configs.workdir
    # Check if nginx_config_dir exists
    Dockup.Configs.nginx_config_dir
    # Ensure "DOCKUP_DOMAIN" config is set
    Dockup.Configs.domain

    # Check if docker and docker-compose versions are ok
    Dockup.Container.check_docker_version

    # Make sure cache container exists
    Dockup.Container.create_cache_container

    # Make sure nginx container is running
    Dockup.Container.run_nginx_container
  end
end
