defmodule ElixirBackendWeb.PageView do
  use ElixirBackendWeb, :view

  def render("chips.json", %{chips: chips}) do
    chips
  end

  def render("ncps.json", %{ncps: ncps}) do
    ncps
  end

end
