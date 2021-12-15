defmodule ElixirBackend.LibObj.NCP do
  use Ecto.Schema
  import Ecto.Query, only: [dynamic: 2]

  @derive {Jason.Encoder, only: [:id, :name, :cost, :color, :description]}
  schema "NaviCust" do
    field :name, :string
    field :description, :string
    field :cost, :integer, source: :size

    field :color, Ecto.Enum, values: [
        white: "White",
        pink: "Pink",
        yellow: "Yellow",
        green: "Green",
        blue: "Blue",
        red: "Red",
        gray: "Gray"
      ]

    field :custom, :boolean

  end

  def gen_conditions(params) do
    # conditions = true

    for {key, value} <- params, reduce: true do
      acc ->
        case key do
          "min_cost" ->
            dynamic([n], n.cost >= ^value and ^acc)
          "max_cost" ->
            dynamic([n], n.cost <= ^value and ^acc)
          "cost" ->
            dynamic([n], n.cost == ^value and ^acc)
          "color" ->
            dynamic([n], n.color == ^value and ^acc)
          "custom" when value == "true" ->
            dynamic([n], n.custom == true and ^acc)
          "custom" when value == "false" ->
            dynamic([n], n.custom == false and ^acc)
        end
    end


    # conditions = unless is_nil(params["min_cost"]) do
    #   dynamic([n], n.cost >= ^params["min_cost"])
    # else
    #   conditions
    # end

    # conditions = unless is_nil(params["max_cost"]) do
    #   dynamic([n], n.cost <= ^params["max_cost"] and ^conditions)
    # else
    #   conditions
    # end

    # conditions = unless is_nil(params["cost"]) do
    #   dynamic([n], n.cost == ^params["cost"] and ^conditions)
    # else
    #   conditions
    # end

    # conditions = unless is_nil(params["color"]) do
    #   color = params["color"] |> String.capitalize(:ascii)
    #   dynamic([n], n.color == ^color and ^conditions)
    # else
    #   conditions
    # end

    # unless is_nil(params["custom"]) do
    #   dynamic([n], n.custom == ^params["custom"] and ^conditions)
    # else
    #   conditions
    # end

  end
end
