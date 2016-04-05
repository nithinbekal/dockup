defmodule Dockup.Haikunator do
  def haiku_subdomain(adjectives, nouns) do
    random_number_as_string = Enum.random(0..9999) |> Integer.to_string |> String.rjust(4, ?0)
    "#{Enum.random(adjectives)}-#{Enum.random(nouns)}-#{random_number_as_string}"
  end

  def adjectives do
    parse_file("adjectives.txt")
  end

  def nouns do
    parse_file("nouns.txt")
  end

  def haikunated_url(haikunator \\ __MODULE__) do
    "#{haiku_subdomain(haikunator.adjectives, haikunator.nouns)}.#{Dockup.Configs.domain}"
  end

  defp parse_file(file) do
    # TODO: Memoize this later
    {:ok, content} = File.read(Application.app_dir(:dockup, "priv") <> "/" <> file)
    String.split(content)
  end
end
