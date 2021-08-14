defmodule ElixirBackendWeb.ChipsController do
  use ElixirBackendWeb, :controller

  def index(conn, _) do
    chips = ElixirBackend.Repo.all(ElixirBackend.LibObj.Battlechip)
    render(conn, "chips.json", chips: chips)
  end

end
