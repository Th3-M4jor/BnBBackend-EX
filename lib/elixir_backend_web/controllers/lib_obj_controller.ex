defmodule ElixirBackendWeb.LibObjController do
  use ElixirBackendWeb, :controller

  alias ElixirBackend.LibObj.{NCP, Virus, Battlechip}
  import Ecto.Query, only: [from: 2]

  plug :verify_params

  def fetch(conn, %{"obj" => kind} = params) do
    # chips = ElixirBackend.Repo.all(Battlechip)
    # json(conn, chips)

    objs =
      try do
        conds = conn.assigns.kind.gen_conditions(params)
        query = from(conn.assigns.kind, where: ^conds)

        {:ok, ElixirBackend.Repo.all(query)}
      rescue
        e ->
          {:error, e}
      end

    case objs do
    {:ok, objs} ->
      render(conn, "libobj.json", kind: kind, objs: objs)
    {:error, _e} ->
      send_resp(conn, 400, "bad parameter")
    end

    # json(conn, objs)
  end

  defp verify_params(conn, _) do
    case conn.params["obj"] do
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
