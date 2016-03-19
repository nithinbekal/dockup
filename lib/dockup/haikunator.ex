defmodule Dockup.Haikunator do
  def start_link(adjectives, nouns) do
    {:ok, _pid} = Agent.start_link(fn -> adjectives end, name: HaikuAdjectives)
    {:ok, _pid} = Agent.start_link(fn -> nouns end, name: HaikuNouns)
    {:ok, self()}
  end

  def haiku_subdomain do
    random_number_as_string = Enum.random(0..9999) |> Integer.to_string |> String.rjust 4, ?0
    "#{get_random_from(HaikuAdjectives)}-#{get_random_from(HaikuNouns)}-#{random_number_as_string}"
  end

  defp get_random_from(name) do
    Enum.random Agent.get(name, fn state -> state end)
  end
end
