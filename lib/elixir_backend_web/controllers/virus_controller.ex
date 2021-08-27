defmodule ElixirBackendWeb.VirusController do
  use ElixirBackendWeb, :controller

  def index(conn, _) do
    viruses = ElixirBackend.Repo.all(ElixirBackend.LibObj.Virus)
    render(conn, "viruses.json", viruses: viruses)
  end

end
