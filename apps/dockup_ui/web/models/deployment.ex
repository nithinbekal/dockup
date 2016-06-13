defmodule DockupUi.Deployment do
  use DockupUi.Web, :model

  schema "deployments" do
    field :git_url, :string
    field :branch, :string
    field :callback_url, :string
    field :status, :string # "deploying" -> "deployed"/"failed" -> "deleted"

    timestamps
  end

  @required_fields ~w(git_url branch)
  @optional_fields ~w(callback_url)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
