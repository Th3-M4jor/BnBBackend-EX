defmodule ElixirBackend.LibObj.Virus.Stats do
  @moduledoc """
  Ecto type mapping for a virus's stats.
  """
  use Ecto.Type

  def type, do: :map

  def cast(%{"mind" => mind, "body" => body, "spirit" => spirit})
      when mind in 1..5 and body in 1..5 and spirit in 1..5 do
    {:ok, %{"mind" => mind, "body" => body, "spirit" => spirit}}
  end

  def cast(%{mind: mind, body: body, spirit: spirit})
      when mind in 1..5 and body in 1..5 and spirit in 1..5 do
    {:ok, %{"mind" => mind, "body" => body, "spirit" => spirit}}
  end

  def cast(_stats), do: :error

  def load(stats) when is_map(stats) do
    {:ok, stats}
  end

  def load(_stats), do: :error

  def dump(stats) when is_map(stats) do
    {:ok, stats}
  end

  def dump(_stats), do: :error
end
