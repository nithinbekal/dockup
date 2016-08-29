%{
  configs: [
    %{
      name: "default",
      files: %{
        included: ["apps/"],
        excluded: ["_build/", "deps/"]
      },
      checks: [
        {Credo.Check.Readability.MaxLineLength, false},
      ]
    }
  ]
}
