defmodule ElixirBackend.LibObj.Dice do
  @moduledoc """
  Ecto Type mapping for die rolls.
  """

  @derive Jason.Encoder
  @enforce_keys [:dienum, :dietype]
  defstruct [:dienum, :dietype]

  @typedoc """
  Represents a dice roll. DieNum is the number of dice to roll, and DieType is the type of dice to roll.
  """
  @type t :: %__MODULE__{
          dienum: non_neg_integer(),
          dietype: non_neg_integer()
        }

  use Ecto.Type

  def type, do: :dice

  def cast(%ElixirBackend.LibObj.Dice{} = dice) do
    {:ok, dice}
  end

  def cast(_) do
    :error
  end

  @spec load({integer(), integer()} | nil) :: {:ok, t() | nil} | :error
  def load({num, size}) when is_integer(num) and is_integer(size) do
    die = %ElixirBackend.LibObj.Dice{dienum: num, dietype: size}
    {:ok, die}
  end

  def load(nil) do
    {:ok, nil}
  end

  def load(_), do: :error

  @spec dump(t() | nil) :: :error | {:ok, {non_neg_integer(), non_neg_integer()} | nil}
  def dump(%ElixirBackend.LibObj.Dice{} = dice) do
    data = {dice.dienum, dice.dietype}
    {:ok, data}
  end

  def dump(nil) do
    {:ok, nil}
  end

  def dump(_), do: :error
end

defmodule ElixirBackend.LibObj.Element do
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

  def type, do: :element

  def cast(elem) when is_list(elem) do
    deduped = Enum.dedup(elem)

    if Enum.all?(deduped, &(&1 in @elements)) do
      {:ok, deduped}
    else
      :error
    end
  end

  def cast(_elem), do: :error

  def load(elem) when is_list(elem) do
    as_atoms = Enum.map(elem, &convert/1)
    {:ok, as_atoms}
  end

  def load(_elem), do: :error

  def dump(elem) when is_list(elem) do
    as_strings =
      Enum.map(elem, fn element ->
        String.Chars.to_string(element) |> String.capitalize(:ascii)
      end)

    {:ok, as_strings}
  end

  def dump(_elem), do: :error

  def convert(elem) when is_atom(elem) do
    elem
  end

  def convert(elem) when is_binary(elem) do
    case String.downcase(elem, :ascii) do
      "fire" -> :fire
      "aqua" -> :aqua
      "elec" -> :elec
      "wood" -> :wood
      "wind" -> :wind
      "sword" -> :sword
      "break" -> :break
      "cursor" -> :cursor
      "recov" -> :recov
      "invis" -> :invis
      "object" -> :object
      "null" -> :null
    end
  end
end

defmodule ElixirBackend.LibObj.Skill do
  @moduledoc """
  Ecto type mapping for all virus skills.
  """
  use Ecto.Type

  @type t :: :per | :inf | :tch | :str | :agi | :end | :chm | :vlr | :aff

  @skills [
    # Perception
    :per,
    # Info
    :inf,
    # Tech
    :tch,
    # Strength
    :str,
    # Agility
    :agi,
    # Endurance
    :end,
    # Charm
    :chm,
    # Valor
    :vlr,
    # Affinity
    :aff
  ]

  def type, do: :skill

  def cast(skills) when is_list(skills) do
    deduped = Enum.dedup(skills)

    if Enum.all?(deduped, &(&1 in @skills)) do
      {:ok, deduped}
    else
      :error
    end
  end

  def cast(_skills), do: :error

  def load(skills) when is_list(skills) do
    as_atoms = Enum.map(skills, &convert/1)
    {:ok, as_atoms}
  end

  def load(_skills), do: :error

  def dump(skills) when is_list(skills) do
    as_strings = Enum.map(skills, fn skill -> to_string(skill) |> String.upcase(:ascii) end)
    {:ok, as_strings}
  end

  def dump(_skills), do: :error

  def convert(skill) when is_atom(skill) do
    skill
  end

  def convert(skill) when is_binary(skill) do
    String.downcase(skill, :ascii) |> String.to_existing_atom()
  end
end

defmodule ElixirBackend.LibObj.Blight do
  @moduledoc """
  Ecto Type mapping for Blight effects.
  """
  use Ecto.Type
  alias ElixirBackend.LibObj.{Element, Dice}

  @derive Jason.Encoder
  @enforce_keys [:elem, :dmg, :duration]
  defstruct [:elem, :dmg, :duration]

  @type t :: %__MODULE__{
          elem: Element.t(),
          dmg: Dice.t() | nil,
          duration: Dice.t() | nil
        }

  def type, do: :blight

  def cast(%ElixirBackend.LibObj.Blight{} = blight) do
    {:ok, blight}
  end

  def cast(_) do
    :error
  end

  def load({elem, dmg, duration}) do
    elem = Element.convert(elem)
    {:ok, dmg} = Dice.load(dmg)
    {:ok, duration} = Dice.load(duration)
    blight = %ElixirBackend.LibObj.Blight{elem: elem, dmg: dmg, duration: duration}
    {:ok, blight}
  end

  def load(nil) do
    {:ok, nil}
  end

  def load(_), do: :error

  def dump(%ElixirBackend.LibObj.Blight{} = blight) do
    data = {blight.elem, blight.dmg, blight.duration}
    {:ok, data}
  end

  def dump(nil) do
    {:ok, nil}
  end

  def dump(_), do: :error
end

defmodule ElixirBackend.LibObj.BadKey do
  @moduledoc """
  Defines the error raised when an invalid query parameter is used
  """
  defexception [:message]

  @impl true
  def exception(key) do
    msg = "Got an unexpected query parameter: #{key}"
    %__MODULE__{message: msg}
  end
end

defmodule ElixirBackend.LibObj.ImproperKey do
  @moduledoc """
  Defines the error raised when a query parameter conflicts
  with another query parameter.
  """

  defexception [:message]

  @impl true
  def exception({limiter, improper_key}) do
    msg = "Query parameters #{limiter} and #{improper_key} are mutually exclusive"
    %__MODULE__{message: msg}
  end
end

defmodule ElixirBackend.LibObj.Query do
  @moduledoc """
  Utility functions for verifying query parameters.
  """

  alias ElixirBackend.LibObj.{BadKey, ImproperKey}

  @spec check_mutually_exclusive(params :: map(), any(), [any()]) :: :ok | no_return()
  def check_mutually_exclusive(params, limiter, improper_keys) when is_map_key(params, limiter) do

    Enum.each(improper_keys, fn improper_key ->
      if is_map_key(params, improper_key) do
        raise ImproperKey, {limiter, improper_key}
      end
    end)

    :ok
  end

  def check_mutually_exclusive(params, _limiter, _improper_keys) when is_map(params) do
    :ok
  end

  @spec validate_keys(params :: map(), valid_keys :: [any()]) :: :ok | no_return()
  def validate_keys(params, valid_keys) when is_map(params) and is_list(valid_keys) do
    param_keys = Map.keys(params)

    Enum.each(param_keys, fn param_key ->
      if param_key not in valid_keys do
        raise BadKey, param_key
      end
    end)

    :ok
  end
end
