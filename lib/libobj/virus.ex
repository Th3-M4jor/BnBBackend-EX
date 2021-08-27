defmodule ElixirBackend.LibObj.VirusStats do
  use Ecto.Type

  def type, do: :virus_stats

  def cast(stats) when is_map(stats) do
    stats
  end

  def cast(_stats), do: :error

  def load(stats) when is_map(stats) do
    stats
  end

  def load(_stats), do: :error

  def dump(stats) when is_map(stats) do
    stats
  end

  def dump(_stats), do: :error
end

defmodule ElixirBackend.LibObj.VirusSkills do
  use Ecto.Type

  def type, do: :virus_skills

  def cast(skills) when is_map(skills) do
    skills
  end

  def cast(_skills), do: :error

  def load(skills) when is_map(skills) do
    skills
  end

  def load(_skills), do: :error

  def dump(skills) when is_map(skills) do
    skills
  end

  def dump(_skills), do: :error
end

defmodule ElixirBackend.LibObj.Virus do
  alias ElixirBackend.LibObj.{Element, Dice, VirusStats, VirusSkills}

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
             :dmgelem
           ]}
  schema "Virus" do
    field :name, :string
    field :element, Element
    field :hp, :integer
    field :ac, :integer
    field :stats, VirusStats
    field :skills, VirusSkills
    field :drops, :map
    field :description, :string
    field :cr, :integer
    field :abilities, {:array, :string}
    field :damage, Dice
    field :dmgelem, Element
  end
end
