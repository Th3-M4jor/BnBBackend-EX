defmodule ElixirBackend.LibObj.NCP do
  use Ecto.Schema
  import Ecto.Query, only: [dynamic: 2]

  # @derive {Jason.Encoder, only: [:id, :name, :cost, :color, :description]}
  schema "NaviCust" do
    field :name, :string
    field :description, :string
    field :cost, :integer, source: :size

    field :color, Ecto.Enum,
      values: [
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

  defimpl Jason.Encoder do
    @ncp_props ~W(id name cost color description custom)a

    def encode(value, opts) do
      list =
        Map.to_list(value)
        |> Stream.filter(fn
          {key, value} when key in @ncp_props and not is_nil(value) -> true
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
        :cost -> 2
        :color -> 3
        :custom -> 4
        :description -> 5
      end
    end
  end

  def gen_conditions(params) do
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
  end
end
