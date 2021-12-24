defmodule ElixirBackend.LibObj.VirusStats do
  use Ecto.Type

  def type, do: :virus_stats

  def cast(stats) when is_map(stats) do
    {:ok, stats}
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
    deduped = Enum.dedup(skills)

    if Enum.all?(deduped, &(&1 in @skills)) do
      {:ok, deduped}
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
    Map.to_list(skills)
    |> Enum.map(fn {skill, num} ->
      skill = to_string(skill) |> String.upcase(:ascii)
      {skill, num}
    end)
    |> Map.new()
  end

  def dump(_skills), do: :error
end

defmodule ElixirBackend.LibObj.VirusDrops do
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
    field :custom, :boolean
  end

  defimpl Jason.Encoder do
    @virus_props ~W(id name element hp ac stats skills drops description cr abilities damage dmgelem blight custom)a

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
        :custom -> 13
        :description -> 14
      end
    end
  end

  def gen_conditions(params) do
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
