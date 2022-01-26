defmodule ElixirBackend.LibObj.Battlechip do
  @moduledoc """
  Ecto Type mapping for battlechips
  """
  alias ElixirBackend.LibObj.{Element, Dice, Blight, Skill}

  use Ecto.Schema
  import Ecto.Query, only: [dynamic: 2]
  import ElixirBackend.CustomQuery

  schema "Battlechip" do
    field :name, :string
    field :elem, Element
    field :skill, Skill

    field :range, Ecto.Enum,
      values: [var: "Varies", self: "Self", close: "Close", near: "Near", far: "Far"]

    field :hits, :string
    field :targets, :string
    field :description, :string

    field :effect, {:array, Ecto.Enum},
      values: [
        :Stagger,
        :Blind,
        :Confuse,
        :Lock,
        :Shield,
        :Barrier,
        :"AC Pierce",
        :"AC Down",
        :Weakness,
        :Aura,
        :Invisible,
        :Paralysis,
        :Panic,
        :Heal,
        :"Dmg Boost",
        :Move
      ]

    field :effduration, :integer
    field :blight, Blight
    field :damage, Dice

    field :kind, Ecto.Enum,
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

    field :class, Ecto.Enum, values: [standard: "Standard", mega: "Mega", giga: "Giga"]

    field :custom, :boolean

    field :cr, :integer

    field :median_hits, :float
    field :median_targets, :float
  end

  defimpl Jason.Encoder do
    @chip_props ~W(id name elem skill range hits targets effect effduration blight damage kind class cr median_hits median_targets description custom)a

    def encode(value, opts) do
      list =
        Map.to_list(value)
        |> Stream.filter(fn
          {key, value} when key in @chip_props and not is_nil(value) -> true
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
        :elem -> 2
        :skill -> 3
        :range -> 4
        :hits -> 5
        :targets -> 6
        :effect -> 7
        :effduration -> 8
        :blight -> 9
        :damage -> 10
        :kind -> 11
        :class -> 12
        :cr -> 13
        :custom -> 14
        :median_hits -> 15
        :median_targets -> 16
        :description -> 17
      end
    end
  end

  @valid_keys ~W(name elem skill range hits targets description effect effduration blight damage kind class custom cr median_hits median_targets)a
  def validate_changeset!(keywords) when is_list(keywords) do
    Keyword.validate!(keywords, @valid_keys)
  end

  def gen_conditions(params) when is_map(params) do
    valid_keys = ~w(elem skill range class kind custom cr min_cr max_cr)

    ElixirBackend.LibObj.Query.validate_keys(params, valid_keys)
    ElixirBackend.LibObj.Query.check_mutually_exclusive(params, "cr", ["min_cr", "max_cr"])

    for {key, value} <- params, reduce: true do
      acc ->
        case key do
          "elem" ->
            elem = String.capitalize(value, :ascii)
            dynamic([b], array_contains(b.elem, ^elem) and ^acc)

          "skill" ->
            skill = String.upcase(value, :ascii)
            dynamic([b], array_contains(b.skill, ^skill) and ^acc)

          "range" ->
            range = String.capitalize(value, :ascii)
            dynamic([b], b.range == ^range and ^acc)

          "class" ->
            class = String.capitalize(value, :ascii)
            dynamic([b], b.class == ^class and ^acc)

          "kind" ->
            kind = String.capitalize(value, :ascii)
            dynamic([b], b.kind == ^kind and ^acc)

          "cr" ->
            dynamic([b], b.cr == ^value and ^acc)

          "min_cr" ->
            dynamic([b], b.cr >= ^value and ^acc)

          "max_cr" ->
            dynamic([b], b.cr <= ^value and ^acc)

          "custom" when value == "true" ->
            dynamic([b], b.custom == true and ^acc)

          "custom" when value == "false" ->
            dynamic([b], b.custom == false and ^acc)
        end
    end
  end
end
