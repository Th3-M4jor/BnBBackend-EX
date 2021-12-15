defmodule ElixirBackendWeb.GroupsController do
  use ElixirBackendWeb, :controller

  alias ElixirBackend.FolderGroups

  def index(conn, _) do
    groups = FolderGroups.get_groups_and_ct()

    unless map_size(groups) == 0 do
      json(conn, groups)
    else
      send_resp(conn, 204, "")
    end
  end
end
