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
    :per,
    :inf,
    :tch,
    :str,
    :agi,
    :end,
    :chm,
    :vlr,
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
    drops = Enum.map(drops, fn [drop, num] ->
      {drop, num}
    end)

    {:ok, Map.new(drops)}
  end

  def dump(_), do: :error
end

defmodule ElixirBackend.LibObj.Virus do
  alias ElixirBackend.LibObj.{Element, Blight, Dice, VirusStats, VirusSkills, VirusDrops}

  use Ecto.Schema

  @derive {Jason.Encoder,
           only: [
             :id,
             :name,
             :element,
             :hp,
             :ac,
             :stats,
             :skills,
             :drops,
             :description,
             :cr,
             :abilities,
             :damage,
             :dmgelem,
             :blight
           ]}
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
end
