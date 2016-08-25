defmodule DockupUi.Types.JSON do
  @behaviour Ecto.Type

  def type, do: :json

  def cast(any), do: {:ok, any}
  def load(value), do: Poison.decode(value)
  def dump(value), do: Poison.encode(value)
end
