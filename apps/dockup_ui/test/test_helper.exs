ExUnit.start

Mix.Task.run "ecto.create", ~w(-r DockupUi.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r DockupUi.Repo --quiet)
{:ok, _} = Application.ensure_all_started(:ex_machina)
Ecto.Adapters.SQL.begin_test_transaction(DockupUi.Repo)
