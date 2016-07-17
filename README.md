# Dockup

This is a redo of chatops_deployer using Elixir to solve the following problems
with the Ruby implementation:

1. Dependency on Ruby
2. Not able to deploy as self contained executable
3. The app is not fault tolerant - sometimes gets stuck
4. Streaming of logs can be done better

Other goals:

1. Better directory structure for cloned repos (check feasibility of git worktree)
2. Ability to list currently deployed apps
3. Ability to write a check to see if app is up
4. Ability to deploy static sites

## Installation

TODO

## Development

Clone the repo and run:

    mix deps.get
    iex -S mix phoenix.server

You can access Dockup UI at http://localhost:4000.

### Development on OSX

    # Install latest elixir
    brew install elixir

    cd dockup
    ./scripts/setup


Once compilation runs fine, you can start dockup.
If you are running this on OSX, unless you have docker CLI available in the
development environment, you need to enable dry run mode in order to start
Dockup. Run:

    # Use this instead of iex -S mix phoenix.server
    DOCKUP_DRY_RUN=true iex -S mix phoenix.server


### Using Vagrant

It is recommended to use Vagrant for the following reasons:

1. You can use real docker and do real deployments on OSX
2. You can destroy containers and restart from a clean slate

A `Vagrantfile` is checked in which will provision an ubuntu machine with
everything ready for testing the app. Here's how you can set it up:

```
$ vagrant up
$ vagrant ssh
$ cd /vagrant
$ ./scripts/setup
```

## Environment variables

Refer `apps/dockup/config/config.exs` to see the list of configurations

## API

### /deployments

This API endpoint is used to deploy a dockerized app.

```
curl -XPOST  -d '{"git_url":"https://github.com/code-mancers/project.git","branch":"master","callback_url":"fake_callback"}' -H "Content-Type: application/json" http://localhost:4000/api/deployments
```
