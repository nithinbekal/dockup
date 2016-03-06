defmodule DeployJob do
  def perform(%{"repository" => repository, "branch" => branch, "callback_url" => callback}) do
    IO.puts "TODO: handle this request for real"
  end
end
