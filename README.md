# Dockup

This is a redo of chatops_deployer using Elixir to solve the following problems
with the Ruby implementation:

1. Dependency on Ruby
2. Not able to deploy as self contained executable
3. The app is not fault tolerant - sometimes gets stuck
4. Streaming of logs can be done better

## Development

Clone the repo and run:

    mix deps.get
    iex -S mix

## Environment variables

```bash
DOCKUP_PORT - Port where dockup should listen for requests. Default "8000".
DOCKUP_BIND - IP address to bind to. Default "0.0.0.0".
```
