defmodule ElixirBackendWeb.RoomChannel do
  @moduledoc """
  Websocket channel for Folder groups.
  """
  require Logger

  use Phoenix.Channel
  intercept ["force_close", "joined", "updated", "player_left"]

  def join("room:" <> group_name, %{"name" => player_name}, socket) do
    Logger.debug("Joining room: #{group_name} Player name: #{player_name}\n")

    # trim whitespace
    player_name = String.trim(player_name)
    group_name = String.trim(group_name)

    # check if group/player name is empty or too long
    cond do
      group_name == "" or
          player_name == "" ->
        {:error, %{reason: "Empty player or group name"}}

      String.length(group_name) > 30 or
          String.length(player_name) > 30 ->
        {:error, %{reason: "Player or group name too long"}}

      name_used?(group_name, player_name) ->
        {:error, %{reason: "name already in use"}}

      true ->
        socket = Map.put(socket, :assigns, %{group_name: group_name, player_name: player_name})
        add_player(group_name, player_name)
        {:ok, socket}
    end
  end

  def handle_in("echo", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  def handle_in("spectate", _payload, socket) do
    Logger.debug([
      "Recieved spectate for ",
      socket.assigns.player_name
    ])

    ElixirBackend.FolderGroups.insert_spectator_and_get(
      socket.assigns.group_name,
      socket.assigns.player_name
    )
    |> case do
      {:ok, folder_group} ->
        res =
          folder_group
          |> Stream.filter(fn {player_name, folder} ->
            player_name != socket.assigns.player_name and folder != :spectator
          end)
          |> Enum.map(fn {player_name, folder} ->
            [player_name, folder]
          end)

        broadcast!(socket, "joined", %{"body" => res})
        {:reply, :ok, socket}

      :error ->
        {:stop, "Group error", {:error, "Group missing"}, socket}
    end
  end

  def handle_in("ready", %{"body" => data}, socket) when is_list(data) do
    Logger.debug([
      "Recieved ready for ",
      socket.assigns.player_name,
      "\npayload: ",
      inspect(data, pretty: true)
    ])

    ElixirBackend.FolderGroups.insert_player_data_and_get(
      socket.assigns.group_name,
      socket.assigns.player_name,
      data
    )
    |> case do
      {:ok, folder_group} ->
        res =
          folder_group
          |> Enum.map(fn {player_name, folder} ->
            [player_name, folder]
          end)

        broadcast!(socket, "joined", %{"body" => res})
        {:reply, :ok, socket}

      :error ->
        {:stop, "Group error", {:error, "Group missing"}, socket}
    end
  end

  def handle_in("ready", payload, socket) do
    Logger.debug(["Invalid ready\n", inspect(payload, pretty: true)])
    {:stop, "invalid ready payload", {:error, "Invalid payload"}, socket}
  end

  def handle_in("update", %{"body" => data}, socket) when is_list(data) do
    Logger.debug([
      "Recieved update for ",
      socket.assigns.player_name,
      "\npayload: ",
      inspect(data, pretty: true)
    ])

    ElixirBackend.FolderGroups.insert_player_data_and_get(
      socket.assigns.group_name,
      socket.assigns.player_name,
      data
    )
    |> case do
      {:ok, folder_group} ->
        res =
          folder_group
          |> Enum.map(fn {player_name, folder} ->
            [player_name, folder]
          end)

        broadcast!(socket, "updated", %{"body" => res, "source" => socket.assigns.player_name})
        {:reply, :ok, socket}

      :error ->
        {:stop, "Group error", {:error, "Group missing"}, socket}
    end
  end

  def handle_in("update", payload, socket) do
    Logger.debug(["Invalid update\n", inspect(payload, pretty: true)])
    {:stop, "invalid update payload", {:error, "Invalid payload"}, socket}
  end

  def handle_out("joined", %{"body" => data}, socket) do
    # remove player's own folder from the list
    data =
      Enum.filter(data, fn [player_name, data] ->
        player_name != socket.assigns.player_name and data != :spectator
      end)

    push(socket, "updated", %{"body" => data})
    {:noreply, socket, :hibernate}
  end

  def handle_out("updated", %{"body" => data, source: name}, socket) do
    unless name == socket.assigns.player_name do
      # remove player's own folder from the list
      data =
        Enum.filter(data, fn [player_name, data] ->
          player_name != socket.assigns.player_name and data != :spectator
        end)

      push(socket, "updated", %{"body" => data})
    end

    {:noreply, socket, :hibernate}
  end

  def handle_out("player_left", %{"body" => data}, socket) do
    data =
      Enum.filter(data, fn [player_name, data] ->
        player_name != socket.assigns.player_name and data != :spectator
      end)

    push(socket, "updated", %{"body" => data})
    {:noreply, socket, :hibernate}
  end

  def handle_out("force_close", _, socket) do
    push(socket, "force_close", %{})
    {:stop, :timedout, socket}
  end

  def terminate(:timeout, socket) do
    Logger.debug(["Timedout for ", socket.assigns[:group_name], ":", socket.assigns[:player_name]])
  end

  def terminate(reason, socket) do
    GenServer.cast(
      :folder_groups,
      {:left, socket.assigns[:group_name], socket.assigns[:player_name]}
    )

    Logger.debug([
      "Terminating: ",
      inspect(reason, pretty: true),
      "\n",
      inspect(socket, pretty: true)
    ])
  end

  defp name_used?(group_name, player_name) do
    case :ets.lookup(:folder_group_tables, group_name) do
      [] -> false
      [{_, {group_table, _}}] -> :ets.member(group_table, player_name)
      _ -> false
    end
  end

  defp add_player(group_name, player_name) do
    group_tid =
      case :ets.lookup(:folder_group_tables, group_name) do
        [] ->
          GenServer.call(:folder_groups, {:add, group_name})

        [{_, {group_table, _}}] ->
          group_table
      end

    :ets.insert(group_tid, {player_name, []})
  end
end
