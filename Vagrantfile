# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  config.vm.network "private_network", ip: "192.168.50.4"

  config.vm.box = "ubuntu/trusty64"
  config.vm.provision "shell", inline: <<-SHELL
    echo 'LC_ALL="en_US.UTF-8"'  >  /etc/default/locale
    cd /home/vagrant

    # Install Elixir
    wget http://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && sudo dpkg -i erlang-solutions_1.0_all.deb
    sudo apt-get update
    sudo apt-get install -y esl-erlang
    sudo apt-get install -y elixir
    echo "Elixir installed"

    sudo apt-get install -y curl build-essential

    # Install NodeJS for dockup_ui
    curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
    sudo apt-get install -y nodejs
    echo "node.js installed"

    # Install postgres for dockup_ui
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
    sudo echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main 9.5" >> /etc/apt/sources.list.d/pgdg.list
    sudo apt-get update
    sudo apt-get -y install postgresql-9.5 postgresql-client-9.5 postgresql-contrib-9.5
    sudo -u postgres createuser -s vagrant
    sudo sh -c "echo 'local all all trust' > /etc/postgresql/9.5/main/pg_hba.conf"
    sudo sh -c "echo 'host all all 127.0.0.1/32 trust' >> /etc/postgresql/9.5/main/pg_hba.conf"
    sudo service postgresql restart
    echo "Postgres 9.5 installed"

    # Install docker
    curl -sSL https://get.docker.com/ | sh
    sudo usermod -aG docker vagrant
    echo "Docker installed"

    # Install docker compose
    sudo sh -c "curl -L https://github.com/docker/compose/releases/download/1.7.1/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose"
    sudo chmod +x /usr/local/bin/docker-compose
    echo "docker-compose installed"
  SHELL

  config.vm.provider "virtualbox" do |v|
    v.memory = 1024
    v.cpus = 2
  end
end
