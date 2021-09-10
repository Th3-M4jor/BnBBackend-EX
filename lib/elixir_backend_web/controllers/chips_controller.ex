defmodule ElixirBackendWeb.ChipsController do
  use ElixirBackendWeb, :controller

  alias ElixirBackend.LibObj.Battlechip

  import Ecto.Query, only: [from: 2]

  def index(conn, _) do
    chips = ElixirBackend.Repo.all(Battlechip)
    render(conn, "chips.json", chips: chips)
  end

  def default(conn, _) do
    chips = ElixirBackend.Repo.all(from c in Battlechip, where: c.custom == false)
    render(conn, "chips.json", chips: chips)
  end

end
