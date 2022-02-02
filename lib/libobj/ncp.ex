defmodule ElixirBackend.LibObj.NCP do
  @moduledoc """
  Ecto type mapping for Navi Customizer parts.
  """

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

    field :custom, :boolean, default: false
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

  @valid_keys ~W(name description cost color custom)a
  def validate_changeset!(keywords) when is_list(keywords) do
    Keyword.validate!(keywords, @valid_keys)
  end

  def get_valid_keys, do: @valid_keys

  def gen_conditions(params) do
    valid_keys = ~w(min_cost max_cost cost color custom)

    ElixirBackend.LibObj.Query.validate_keys(params, valid_keys)
    ElixirBackend.LibObj.Query.check_mutually_exclusive(params, "cost", ["min_cost", "max_cost"])

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
