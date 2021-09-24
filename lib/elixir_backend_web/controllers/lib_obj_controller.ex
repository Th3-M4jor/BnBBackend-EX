defmodule ElixirBackendWeb.LibObjController do
  use ElixirBackendWeb, :controller

  alias ElixirBackend.LibObj.{NCP, Virus, Battlechip}
  import Ecto.Query, only: [from: 2]

  plug :verify_params

  def fetch(conn, %{"kind" => kind}) do
    #chips = ElixirBackend.Repo.all(Battlechip)
    #json(conn, chips)

    objs = ElixirBackend.Repo.all(conn.assigns.kind)
    #json(conn, objs)

    render(conn, "libobj.json", kind: kind, objs: objs)

  end

  def fetch_no_custom(conn, %{"kind" => kind}) do

    objs = ElixirBackend.Repo.all(from o in conn.assigns.kind, where: o.custom == false)

    #json(conn, objs)

    render(conn, "libobj.json", kind: kind, objs: objs)

  end

  defp verify_params(conn, _) do
    case conn.params["kind"] do
      "ncps" ->
        conn |> assign(:kind, NCP)
      "viruses" ->
        conn |> assign(:kind, Virus)
      "chips" ->
        conn |> assign(:kind, Battlechip)
      _ ->
        conn |> send_resp(404, "Only chips, ncps, and viruses are allowed") |> halt()
    end
  end
end
