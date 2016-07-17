Dockup
======

This is the core library of Dockup which is used by DockupUi phoenix app to
deploy and manage apps.

## Development

```
# Fetch dependencies and compile:
mix local.hex
mix deps.get
mix compile
```

If you are running this on OSX, unless you have docker CLI available in the
development environment, you need to enable dry run mode in order to start
Dockup. Run:

    DOCKUP_DRY_RUN=true iex -S mix
