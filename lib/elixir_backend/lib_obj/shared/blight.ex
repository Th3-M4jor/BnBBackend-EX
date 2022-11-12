defmodule ElixirBackend.LibObj.Shared.Blight do
  @moduledoc """
  Ecto Type mapping for Blight effects.
  """
  use Ecto.Type
  alias ElixirBackend.LibObj.Shared.{Element, Dice}

  @derive Jason.Encoder
  @enforce_keys [:elem, :dmg, :duration]
  defstruct [:elem, :dmg, :duration]

  @type t :: %__MODULE__{
          elem: Element.t(),
          dmg: Dice.t() | nil,
          duration: Dice.t() | nil
        }

  def type, do: :blight

  def cast(%__MODULE__{} = blight) do
    {:ok, blight}
  end

  def cast({elem, dmg, duration}) do
    load({elem, dmg, duration})
  end

  def cast(_) do
    :error
  end

  def load({elem, dmg, duration}) do
    with {:ok, elem} <- Element.convert(elem),
         {:ok, dmg} <- Dice.load(dmg),
         {:ok, duration} <- Dice.load(duration) do
      {:ok, %__MODULE__{elem: elem, dmg: dmg, duration: duration}}
    else
      _ -> :error
    end
  end

  def load(_), do: :error

  def dump(%__MODULE__{elem: elem, dmg: dmg, duration: duration}) do
    elem = Atom.to_string(elem) |> String.capitalize(:ascii)

    with {:ok, dmg} <- Dice.dump(dmg),
         {:ok, duration} <- Dice.dump(duration) do
      {:ok, {elem, dmg, duration}}
    else
      _ -> :error
    end
  end

  def dump(_), do: :error
end
