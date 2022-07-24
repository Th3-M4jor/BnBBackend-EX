defmodule ElixirBackend.LibObj.Virus.Drops do
  @moduledoc """
  Ecto Type mapping for Virus Drops.
  """

  use Ecto.Type

  def type, do: :map

  def cast(drops) when is_map(drops) do
    drops =
      Map.to_list(drops)
      |> Enum.map(fn {drop, num} ->
        [drop, num]
      end)

    {:ok, drops}
  end

  def cast(_), do: :error

  def load(drops) when is_map(drops) do
    drops =
      Map.to_list(drops)
      |> Enum.map(fn {drop, num} ->
        [drop, num]
      end)

    {:ok, drops}
  end

  def load(_), do: :error

  def dump(drops) when is_map(drops) do
    {:ok, drops}
  end

  def dump(drops) when is_list(drops) do
    drops =
      Enum.map(drops, fn [drop, num] ->
        {drop, num}
      end)

    {:ok, Map.new(drops)}
  end

  def dump(_), do: :error
end
