defmodule ElixirBackend.LibObj.Shared.Skill do
  @moduledoc """
  Ecto type mapping for all virus/battlechip skills.
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

  def cast(skill) when skill in @skills do
    {:ok, [skill]}
  end

  def cast(nil), do: nil

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

  def convert(skill) when skill in @skills do
    skill
  end

  def convert(skill) when is_binary(skill) do
    String.downcase(skill, :ascii) |> String.to_existing_atom()
  end
end
