defmodule ElixirBackend.LibObj.Battlechip do
  alias ElixirBackend.LibObj.{Element, Dice, Blight, Skill}

  use Ecto.Schema

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

    field :range, Ecto.Enum,
      values: [var: "Varies", self: "Self", close: "Close", near: "Near", far: "Far"]

    field :hits, :string
    field :targets, :integer
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
  end

end
