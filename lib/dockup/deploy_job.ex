defmodule DeployJob do
  def spawn_process(%{"repository" => repository, "branch" => branch, "callback_url" => callback_url}) do
    spawn(fn -> perform(repository, branch, callback_url) end)
  end

  defp perform(repository, branch, callback_url) do
    IO.puts "Spawned process #{inspect self()} to perform deployment"
  end
end
