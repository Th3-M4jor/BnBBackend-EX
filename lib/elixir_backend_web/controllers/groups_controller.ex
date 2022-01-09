defmodule ElixirBackendWeb.GroupsController do
  use ElixirBackendWeb, :controller

  alias ElixirBackend.FolderGroups

  def index(conn, _) do
    groups = FolderGroups.get_groups_and_ct()

    if map_size(groups) == 0 do
      send_resp(conn, 204, "")
    else
      json(conn, groups)
    end
  end
end
