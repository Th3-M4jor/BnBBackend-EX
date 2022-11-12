defmodule ElixirBackend.LibObj.Virus.Drops do
  @moduledoc """
  Ecto Type mapping for Virus Drops.
  """

  use Ecto.Type

  def type, do: :map

  def cast(drops) when is_map(drops) do
    drops =
      Map.to_list(drops)
      |> Enum.map(&Tuple.to_list/1)

    {:ok, drops}
  end

  def cast(_), do: :error

  def load(drops) when is_map(drops) do
    drops =
      Map.to_list(drops)
      |> Enum.map(&Tuple.to_list/1)

    {:ok, drops}
  end

  def load(_), do: :error

  def dump(drops) when is_map(drops) do
    {:ok, drops}
  end

  def dump(drops) when is_list(drops) do
    drops =
      drops
      |> Enum.map(&List.to_tuple/1)
      |> Map.new()

    {:ok, drops}
  end

  def dump(_), do: :error
end
