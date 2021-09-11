defmodule ElixirBackendWeb.VirusController do
  use ElixirBackendWeb, :controller

  alias ElixirBackend.LibObj.Virus

  import Ecto.Query, only: [from: 2]
  def index(conn, _) do
    viruses = ElixirBackend.Repo.all(Virus)
    json(conn, viruses)
  end

  def default(conn, _) do
    viruses = ElixirBackend.Repo.all(from v in Virus, where: v.custom == false)
    json(conn, viruses)
  end

end
