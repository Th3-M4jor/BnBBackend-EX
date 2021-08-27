defmodule ElixirBackendWeb.ChipsView do
  use ElixirBackendWeb, :view

  def render("chips.json", %{chips: chips}) do
    chips
  end

end
