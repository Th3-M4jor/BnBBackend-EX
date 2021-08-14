defmodule ElixirBackendWeb.NcpsController do
  use ElixirBackendWeb, :controller

  def index(conn, _) do
    ncps = ElixirBackend.Repo.all(ElixirBackend.LibObj.NCP)
    render(conn, "ncps.json", ncps: ncps)
  end

end
