defmodule ElixirBackendWeb.VirusController do
  use ElixirBackendWeb, :controller

  alias ElixirBackend.LibObj.Virus

  import Ecto.Query, only: [from: 2]
  def index(conn, _) do
    viruses = ElixirBackend.Repo.all(Virus)
    render(conn, "viruses.json", viruses: viruses)
  end

  def default(conn, _) do
    viruses = ElixirBackend.Repo.all(from v in Virus, where: v.custom == false)
    render(conn, "viruses.json", viruses: viruses)
  end

end
