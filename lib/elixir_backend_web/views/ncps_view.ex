defmodule ElixirBackendWeb.NcpsView do
  use ElixirBackendWeb, :view

  def render("ncps.json", %{ncps: ncps}) do
    ncps
  end

end
