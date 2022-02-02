defmodule ElixirBackend.LibObj.VirusStats do
  @moduledoc """
  Ecto type mapping for a virus's stats.
  """
  use Ecto.Type

  def type, do: :virus_stats

  def cast(%{"mind" => mind, "body" => body, "spirit" => spirit})
      when mind in 1..5 and body in 1..5 and spirit in 1..5 do
    {:ok, %{"mind" => mind, "body" => body, "spirit" => spirit}}
  end

  def cast(%{mind: mind, body: body, spirit: spirit})
      when mind in 1..5 and body in 1..5 and spirit in 1..5 do
    {:ok, %{"mind" => mind, "body" => body, "spirit" => spirit}}
  end

  def cast(_stats), do: :error

  def load(stats) when is_map(stats) do
    {:ok, stats}
  end

  def load(_stats), do: :error

  def dump(stats) when is_map(stats) do
    {:ok, stats}
  end

  def dump(_stats), do: :error
end

defmodule ElixirBackend.LibObj.VirusSkills do
  @moduledoc """
  Ecto Type mapping for a Virus's Skills.
  """

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

  def type, do: :virus_skills

  def cast(skills) when is_map(skills) do
    keys = Map.keys(skills) |> Enum.map(&ElixirBackend.LibObj.Skill.convert/1)
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
        skill = ElixirBackend.LibObj.Skill.convert(skill)
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

defmodule ElixirBackend.LibObj.VirusDrops do
  @moduledoc """
  Ecto Type mapping for Virus Drops.
  """

  use Ecto.Type

  def type, do: :virus_drops

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

defmodule ElixirBackend.LibObj.Virus do
  @moduledoc """
  Ecto schema mapping for a Virus.
  """

  alias ElixirBackend.LibObj.{Element, Blight, Dice, VirusStats, VirusSkills, VirusDrops}

  use Ecto.Schema
  import Ecto.Query, only: [dynamic: 2]
  import ElixirBackend.CustomQuery

  schema "Virus" do
    field :name, :string
    field :element, Element
    field :hp, :integer
    field :ac, :integer
    field :stats, VirusStats
    field :skills, VirusSkills
    field :drops, VirusDrops
    field :description, :string
    field :cr, :integer
    field :abilities, {:array, :string}
    field :damage, Dice
    field :dmgelem, Element
    field :blight, Blight
    field :custom, :boolean, default: false

    field :attack_kind, Ecto.Enum,
      values: [
        melee: "Melee",
        projectile: "Projectile",
        wave: "Wave",
        burst: "Burst",
        summon: "Summon",
        construct: "Construct",
        support: "Support",
        heal: "Heal",
        trap: "Trap"
      ]
  end

  defimpl Jason.Encoder do
    @virus_props ~W(id name element hp ac stats skills drops description cr abilities damage dmgelem blight custom attack_kind)a

    def encode(value, opts) do
      list =
        Map.to_list(value)
        |> Stream.filter(fn
          {key, value} when key in @virus_props and not is_nil(value) -> true
          _ -> false
        end)
        |> Enum.sort_by(fn {key, _} -> key_to_sort_num(key) end)
        |> Stream.map(fn {key, value} ->
          [
            Jason.Encode.atom(key, opts),
            ":",
            Jason.Encoder.encode(value, opts)
          ]
        end)
        |> Enum.intersperse(",")

      [
        "{",
        list,
        "}"
      ]
    end

    defp key_to_sort_num(key) do
      case key do
        :id -> 0
        :name -> 1
        :element -> 2
        :hp -> 3
        :ac -> 4
        :stats -> 5
        :skills -> 6
        :drops -> 7
        :cr -> 8
        :abilities -> 9
        :damage -> 10
        :dmgelem -> 11
        :blight -> 12
        :attack_kind -> 13
        :custom -> 14
        :description -> 15
      end
    end
  end

  @valid_keys ~W(name element hp ac stats skills drops description cr abilities damage dmgelem blight custom attack_kind)a
  def validate_changeset!(keywords) when is_list(keywords) do
    Keyword.validate!(keywords, @valid_keys)
  end

  def get_valid_keys, do: @valid_keys

  def gen_conditions(params) do
    valid_keys = ~w(elem min_cr max_cr cr min_hp max_hp min_ac max_ac custom)

    ElixirBackend.LibObj.Query.validate_keys(params, valid_keys)
    ElixirBackend.LibObj.Query.check_mutually_exclusive(params, "cr", ["min_cr", "max_cr"])

    for {key, value} <- params, reduce: true do
      acc ->
        case key do
          "elem" ->
            elem = String.capitalize(value, :ascii)
            dynamic([v], array_contains(v.element, ^elem) and ^acc)

          "min_cr" ->
            dynamic([v], v.cr >= ^value and ^acc)

          "max_cr" ->
            dynamic([v], v.cr <= ^value and ^acc)

          "cr" ->
            dynamic([v], v.cr == ^value and ^acc)

          "min_hp" ->
            dynamic([v], v.hp >= ^value and ^acc)

          "max_hp" ->
            dynamic([v], v.hp <= ^value and ^acc)

          "min_ac" ->
            dynamic([v], v.ac >= ^value and ^acc)

          "max_ac" ->
            dynamic([v], v.ac <= ^value and ^acc)

          "custom" when value == "true" ->
            dynamic([v], v.custom == true and ^acc)

          "custom" when value == "false" ->
            dynamic([v], v.custom == false and ^acc)
        end
    end
  end
end
