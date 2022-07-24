defmodule ElixirBackend.LibObj.Shared.Element do
  @moduledoc """
  Ecto Type mapping for all the elements in the game.
  """
  use Ecto.Type

  @type t ::
          :fire
          | :aqua
          | :elec
          | :wood
          | :wind
          | :sword
          | :break
          | :cursor
          | :recov
          | :invis
          | :object
          | :null

  @elements [
    :fire,
    :aqua,
    :elec,
    :wood,
    :wind,
    :sword,
    :break,
    :cursor,
    :recov,
    :invis,
    :object,
    :null
  ]

  def type, do: :string

  def cast(elem) when is_list(elem) do
    deduped = Enum.uniq(elem)

    if Enum.all?(deduped, &(&1 in @elements)) do
      {:ok, deduped}
    else
      :error
    end
  end

  def cast(elem) when elem in @elements do
    {:ok, [elem]}
  end

  def cast(_elem), do: :error

  def load(elems) when is_list(elems) do
    res =
      Enum.reduce_while(elems, [], fn elem, acc ->
        case convert(elem) do
          # list append here is fine, since there are only 12 elements
          {:ok, elem} -> {:cont, acc ++ [elem]}
          :error -> {:halt, :error}
        end
      end)

    if res == :error do
      :error
    else
      {:ok, res}
    end
  end

  def load(_elem), do: :error

  def dump(elem) when is_list(elem) do
    as_strings =
      Enum.map(elem, fn element ->
        String.Chars.to_string(element) |> String.capitalize(:ascii)
      end)

    {:ok, as_strings}
  end

  def dump(elem) when elem in @elements do
    {:ok, [String.Chars.to_string(elem) |> String.capitalize(:ascii)]}
  end

  def dump(_elem), do: :error

  @spec convert(any) :: :error | {:ok, t()}
  def convert(elem) when elem in @elements do
    {:ok, elem}
  end

  def convert(elem) when is_binary(elem) do
    case String.downcase(elem, :ascii) do
      "fire" -> {:ok, :fire}
      "aqua" -> {:ok, :aqua}
      "elec" -> {:ok, :elec}
      "wood" -> {:ok, :wood}
      "wind" -> {:ok, :wind}
      "sword" -> {:ok, :sword}
      "break" -> {:ok, :break}
      "cursor" -> {:ok, :cursor}
      "recov" -> {:ok, :recov}
      "invis" -> {:ok, :invis}
      "object" -> {:ok, :object}
      "null" -> {:ok, :null}
      _ -> :error
    end
  end

  def convert(_elem), do: :error
end
