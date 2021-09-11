defmodule ElixirBackendWeb.NcpsController do
  use ElixirBackendWeb, :controller

  alias ElixirBackend.LibObj.NCP
  import Ecto.Query, only: [from: 2]

  def index(conn, _) do
    ncps = ElixirBackend.Repo.all(NCP)
    json(conn, ncps)
  end

  def default(conn, _) do
    ncp = ElixirBackend.Repo.all(from n in NCP, where: n.custom == false)
    json(conn, ncp)
  end

end
