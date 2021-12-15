defmodule ElixirBackend.LibObj.Battlechip do
  alias ElixirBackend.LibObj.{Element, Dice, Blight, Skill}

  use Ecto.Schema
  import Ecto.Query, only: [dynamic: 2]
  import ElixirBackend.CustomQuery

  @derive {Jason.Encoder,
           only: [
             :id,
             :name,
             :elem,
             :skill,
             :range,
             :hits,
             :targets,
             :effect,
             :effduration,
             :blight,
             :damage,
             :kind,
             :class,
             :description
           ]}
  schema "Battlechip" do
    field :name, :string
    field :elem, Element
    field :skill, Skill

    field :range, Ecto.Enum, values: [var: "Varies", self: "Self", close: "Close", near: "Near", far: "Far"]

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

  #def gen_conditions(params) when map_size(params) == 0, do: true

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
            #custom = value == "true"
            dynamic([b], b.custom == true and ^acc)
          "custom" when value == "false" ->
            dynamic([b], b.custom == false and ^acc)
      end
    end

    # conditions = unless is_nil(params["elem"]) do
    #   elem = params["elem"] |> String.capitalize(:ascii)
    #   dynamic([b], array_contains(b.elem, ^elem))
    # else
    #   conditions
    # end

    # conditions = unless is_nil(params["skill"]) do
    #   skill = params["skill"] |> String.upcase(:ascii)
    #   dynamic([b], array_contains(b.skill, ^skill) and ^conditions)
    # else
    #   conditions
    # end

    # conditions = unless is_nil(params["range"]) do
    #   range = params["range"] |> String.capitalize(:ascii)
    #   dynamic([b], b.range == ^range and ^conditions)
    # else
    #   conditions
    # end

    # conditions = unless is_nil(params["class"]) do
    #   class = params["class"] |> String.capitalize(:ascii)
    #   dynamic([b], b.class == ^class and ^conditions)
    # else
    #   conditions
    # end

    # conditions = unless is_nil(params["kind"]) do
    #   kind = params["kind"] |> String.capitalize(:ascii)
    #   dynamic([b], b.kind == ^kind and ^conditions)
    # else
    #   conditions
    # end

    # unless is_nil(params["custom"]) do
    #   dynamic([b], b.custom == ^params["custom"] and ^conditions)
    # else
    #   conditions
    # end

  end


end
