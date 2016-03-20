defmodule Dockup.HaikunatorTest do
  use ExUnit.Case

  test "haiku_subdomain returns a haikunated subdomain in the format <adjective>-<noun>-<4 digits>" do
    Dockup.Haikunator.start_link(["arrogant"], ["man"])
    subdomain = Dockup.Haikunator.haiku_subdomain
    matches = Regex.named_captures(~r/(?<adjective>\w+)-(?<noun>\w+)-\d{4}/, subdomain)
    assert matches["adjective"] == "arrogant"
    assert matches["noun"] == "man"
  end
end
