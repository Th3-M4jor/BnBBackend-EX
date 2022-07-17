defmodule ElixirBackendWeb.FallbackController do
  use ElixirBackendWeb, :controller

  def fallback(conn, _) do
    send_resp(conn, 404, "")
  end
end
