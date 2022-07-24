defmodule ElixirBackend.LibObj.Virus.Skills do
  @moduledoc """
  Ecto Type mapping for a Virus's Skills.
  """

  alias ElixirBackend.LibObj.Shared.Skill

  use Ecto.Type

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

  def type, do: :map

  def cast(skills) when is_map(skills) do
    keys = Map.keys(skills) |> Enum.map(&Skill.convert/1)
    values = Map.values(skills)

    if Enum.all?(keys, &(&1 in @skills)) and Enum.all?(values, &(&1 in 1..20)) do
      {:ok, skills}
    else
      :error
    end
  end

  def cast(_skills), do: :error

  def load(skills) when is_map(skills) do
    skills =
      Map.to_list(skills)
      |> Enum.map(fn {skill, num} ->
        skill = Skill.convert(skill)
        {skill, num}
      end)
      |> Map.new()

    {:ok, skills}
  end

  def load(_skills), do: :error

  def dump(skills) when is_map(skills) do
    skills =
      skills
      |> Enum.map(fn {skill, num} ->
        skill = to_string(skill) |> String.upcase(:ascii)
        {skill, num}
      end)
      |> Map.new()

    {:ok, skills}
  end

  def dump(_skills), do: :error
end
