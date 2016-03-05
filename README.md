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
    iex -S mix

## Environment variables

```bash
DOCKUP_PORT - Port where dockup should listen for requests. Default "8000".
DOCKUP_BIND - IP address to bind to. Default "0.0.0.0".
```
