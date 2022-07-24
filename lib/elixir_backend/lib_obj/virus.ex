defmodule ElixirBackend.LibObj.Virus do
  @moduledoc """
  Ecto schema mapping for a Virus.
  """

  alias ElixirBackend.LibObj.Virus.{Stats, Skills, Drops}
  alias ElixirBackend.LibObj.Shared.{Blight, Dice, Element}

  use Ecto.Schema
  import Ecto.Query, only: [dynamic: 2]
  import ElixirBackend.CustomQuery

  schema "Virus" do
    field :name, :string
    field :element, Element
    field :hp, :integer
    field :ac, :integer
    field :stats, Stats
    field :skills, Skills
    field :drops, Drops
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
      Map.to_list(value)
      |> Stream.filter(fn {key, value} ->
        key in @virus_props and value != nil
      end)
      |> Enum.sort_by(fn {key, _} -> key_to_sort_num(key) end)
      |> Jason.Encode.keyword(opts)
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

  @doc """
  Converts a set of URL query parameters into a WHERE clause.
  """
  def gen_conditions(params) do
    valid_keys = ~w(elem min_cr max_cr cr min_hp max_hp min_ac max_ac custom)

    ElixirBackend.LibObj.Query.validate_keys!(params, valid_keys)
    ElixirBackend.LibObj.Query.check_mutually_exclusive!(params, "cr", ["min_cr", "max_cr"])

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
