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

## Development

Clone the repo and run:

    mix deps.get
    iex -S mix phoenix.server

You can access Dockup UI at http://localhost:4000.

### Development on OSX

If you are running this on OSX, unless you have docker CLI available in the
development environment, you need to enable dry run mode in order to start
Dockup. Run:

    # Use this instead of iex -S mix phoenix.server
    DOCKUP_DRY_RUN=true iex -S mix phoenix.server


### Using Vagrant for testing

A `Vagrantfile` is checked in which will provision an ubuntu machine with
everything ready for testing the app. Here's how you can set it up:

```
$ vagrant up
$ vagrant ssh
$ mix local.hex
$ mix deps.get
$ mix clean
$ mix compile
```

## Environment variables

Refer `config/config.exs` to see the list of configurations

## API

### /deploy

This API endpoint is used to deploy a dockerized app.

```
curl -XPOST  -d '{"repository":"https://github.com/code-mancers/project.git","branch":"master","callback_url":"fake_callback"}' -H "Content-Type: application/json" http://localhost:8000/deploy
```
