defmodule ElixirBackendWeb.LibObjController do
  use ElixirBackendWeb, :controller

  alias ElixirBackend.LibObj.{NCP, Virus, Battlechip}
  import Ecto.Query, only: [from: 2]

  def index(conn, %{"kind" => libobj_kind}) do
    fetch_libobjs(conn, libobj_kind)
  end

  def default(conn, %{"kind" => libobj_kind}) do
    fetch_libobjs_default(conn, libobj_kind)
  end

  defp fetch_libobjs(conn, "chips") do
    chips = ElixirBackend.Repo.all(Battlechip)
    json(conn, chips)
  end

  defp fetch_libobjs(conn, "viruses") do
    viruses = ElixirBackend.Repo.all(Virus)
    json(conn, viruses)
  end

  defp fetch_libobjs(conn, "ncps") do
    ncps = ElixirBackend.Repo.all(NCP)
    json(conn, ncps)
  end

  defp fetch_libobjs(conn, _unknown) do
    conn
    |> send_resp(404, "")
  end

  defp fetch_libobjs_default(conn, "chips") do
    chips = ElixirBackend.Repo.all(from c in Battlechip, where: c.custom == false)
    json(conn, chips)
  end

  defp fetch_libobjs_default(conn, "viruses") do
    viruses = ElixirBackend.Repo.all(from v in Virus, where: v.custom == false)
    json(conn, viruses)
  end

  defp fetch_libobjs_default(conn, "ncps") do
    ncps = ElixirBackend.Repo.all(from n in NCP, where: n.custom == false)
    json(conn, ncps)
  end

  defp fetch_libobjs_default(conn, _unknown) do
    conn
    |> send_resp(404, "")
  end

end
