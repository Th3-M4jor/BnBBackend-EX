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

    field :conflicts, {:array, :string}

    field :custom, :boolean, default: false
  end

  defimpl Jason.Encoder do
    @ncp_props ~W(id name cost color conflicts description custom)a

    def encode(value, opts) do
      Map.to_list(value)
      |> Stream.filter(fn {key, value} ->
        key in @ncp_props and value != nil
      end)
      |> Enum.sort_by(fn {key, _} -> key_to_sort_num(key) end)
      |> Jason.Encode.keyword(opts)
    end

    defp key_to_sort_num(key) do
      case key do
        :id -> 0
        :name -> 1
        :cost -> 2
        :color -> 3
        :conflicts -> 4
        :custom -> 5
        :description -> 6
      end
    end
  end

  @valid_keys ~W(name description cost color custom conflicts)a
  def validate_changeset!(keywords) when is_list(keywords) do
    Keyword.validate!(keywords, @valid_keys)
  end

  def get_valid_keys, do: @valid_keys

  def gen_conditions(params) do
    valid_keys = ~w(min_cost max_cost cost color custom)

    ElixirBackend.LibObj.Query.validate_keys!(params, valid_keys)
    ElixirBackend.LibObj.Query.check_mutually_exclusive!(params, "cost", ["min_cost", "max_cost"])

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
