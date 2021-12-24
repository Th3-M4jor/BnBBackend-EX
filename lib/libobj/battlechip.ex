defmodule ElixirBackend.LibObj.Battlechip do
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
    field :effect, {:array, :string}
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
  end

  defimpl Jason.Encoder do
    @chip_props ~W(id name elem skill range hits targets effect effduration blight damage kind class description custom)a

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
        :custom -> 13
        :description -> 14
      end
    end
  end

  def gen_conditions(params) do
    # conditions = true

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

          "custom" when value == "true" ->
            dynamic([b], b.custom == true and ^acc)

          "custom" when value == "false" ->
            dynamic([b], b.custom == false and ^acc)
        end
    end
  end
end
