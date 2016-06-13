defmodule DockupUi.DeploymentTest do
  use DockupUi.ModelCase

  alias DockupUi.Deployment

  @valid_attrs %{git_url: "foo", branch: "bar", callback_url: "baz"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Deployment.changeset(%Deployment{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Deployment.changeset(%Deployment{}, @invalid_attrs)
    refute changeset.valid?
  end
end
