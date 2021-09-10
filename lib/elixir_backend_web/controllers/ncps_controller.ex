defmodule ElixirBackendWeb.NcpsController do
  use ElixirBackendWeb, :controller

  alias ElixirBackend.LibObj.NCP
  import Ecto.Query, only: [from: 2]

  def index(conn, _) do
    ncps = ElixirBackend.Repo.all(NCP)
    render(conn, "ncps.json", ncps: ncps)
  end

  def default(conn, _) do
    ncp = ElixirBackend.Repo.all(from n in NCP, where: n.custom == false)
    render(conn, "ncps.json", ncps: ncp)
  end

end
