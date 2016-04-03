defmodule Dockup.HaikunatorTest do
  use ExUnit.Case

  test "haiku_subdomain returns a haikunated subdomain in the format <adjective>-<noun>-<4 digits>" do
    subdomain = Dockup.Haikunator.haiku_subdomain(["arrogant"], ["man"])
    matches = Regex.named_captures(~r/(?<adjective>\w+)-(?<noun>\w+)-\d{4}/, subdomain)
    assert matches["adjective"] == "arrogant"
    assert matches["noun"] == "man"
  end

  test "adjectives is a list of 100 adjectives" do
    assert length(Dockup.Haikunator.adjectives) == 100
    assert List.first(Dockup.Haikunator.adjectives) == "confident"
  end

  test "nouns is a list of 100 nouns" do
    assert length(Dockup.Haikunator.nouns) == 100
    assert List.first(Dockup.Haikunator.nouns) == "climate"
  end

  test "haikunated_url creates a url using haiku_subdomain" do
    defmodule DummyHaikunator do
      def adjectives, do: ["arrogant"]
      def nouns, do: ["lady"]
    end

    assert Dockup.Haikunator.haikunated_url(DummyHaikunator) =~ ~r/arrogant-lady-\d{4}.127.0.0.1.xip.io/
  end
end
