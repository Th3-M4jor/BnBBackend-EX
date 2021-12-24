defmodule ElixirBackend.FolderGroups do
  require Logger

  use GenServer

  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg, name: :folder_groups)
  end

  @impl true
  def init(_) do
    tid =
      :ets.new(:folder_group_tables, [
        :set,
        :protected,
        :named_table,
        read_concurrency: true
      ])

    schedule_cleanup()
    {:ok, tid}
  end

  @impl true
  @spec handle_call({:add, String.t()}, GenServer.from(), :ets.tab()) ::
          {:reply, :ets.tab(), :ets.tab()}
  def handle_call({:add, name}, _from, tid) do
    Logger.debug(["Creating group: ", name])

    group_id =
      case :ets.lookup(tid, name) do
        [] ->
          # No group with this name exists yet, create it
          group_table =
            :ets.new(:foo, [:set, :public, read_concurrency: true, write_concurrency: true])

          now = System.monotonic_time() |> System.convert_time_unit(:native, :millisecond)
          # insert new group into global table
          :ets.insert(tid, {name, {group_table, now}})
          group_table

        [{_group_name, {group_table_id, _timeout}}] ->
          group_table_id
      end

    {:reply, group_id, tid}
  end

  @impl true
  @spec handle_cast({:left, String.t(), String.t()}, :ets.tab()) :: {:noreply, :ets.tab()}
  def handle_cast({:left, group_name, player_name}, tid) do
    Logger.debug(["Player ", player_name, " left group: ", group_name])
    group_table = :ets.lookup(tid, group_name)
    player_left(group_name, player_name, group_table, tid)
    {:noreply, tid}
  end

  @impl true
  @spec handle_info(:cleanup, :ets.tab()) :: {:noreply, :ets.tab()}
  def handle_info(:cleanup, tid) do
    limit =
      (System.monotonic_time() |> System.convert_time_unit(:native, :millisecond)) -
        :timer.hours(12)

    pairs =
      :ets.select(tid, [{{:"$1", {:"$2", :"$3"}}, [{:<, :"$3", limit}], [{{:"$1", :"$2"}}]}])

    bot_node = Application.fetch_env!(:elixir_backend, :bot_node_name)

    Enum.each(pairs, fn {name, table} ->
      ElixirBackendWeb.Endpoint.broadcast("room:#{name}", "force_close", %{})

      if Node.alive?() and Node.connect(bot_node) do
        :erpc.cast(bot_node, BnBBot.Commands.Groups, :group_force_closed, [name])
      end

      :ets.delete(tid, name)
      :ets.delete(table)
    end)

    schedule_cleanup()

    {:noreply, tid}
  end

  @spec insert_player_data_and_get(String.t(), String.t(), list()) :: {:ok, list()} | :error
  def insert_player_data_and_get(group_name, player_name, data) do
    # [{_, {group_tid, _}}] = :ets.lookup(:folder_group_tables, group_name)
    group = :ets.lookup(:folder_group_tables, group_name)

    case group do
      [] ->
        :error

      [{_, {group_tid, _}}] ->
        :ets.insert(group_tid, {player_name, data})
        {:ok, :ets.tab2list(group_tid)}
    end
  end

  @spec insert_spectator_and_get(String.t(), String.t()) :: {:ok, list()} | :error
  def insert_spectator_and_get(group_name, player_name) do
    group = :ets.lookup(:folder_group_tables, group_name)

    case group do
      [] ->
        :error

      [{_, {group_tid, _}}] ->
        :ets.insert(group_tid, {player_name, :spectator})
        {:ok, :ets.tab2list(group_tid)}
    end
  end

  @spec get_groups_and_ct() :: %{
          String.t() => %{count: non_neg_integer(), spectators: non_neg_integer()}
        }
  def get_groups_and_ct() do
    for {name, {group_tid, _}} <- :ets.tab2list(:folder_group_tables), into: %{} do
      len = :ets.info(group_tid, :size)

      spectators =
        :ets.select_count(group_tid, [{{:"$1", :"$2"}, [{:==, :"$2", :spectator}], [true]}])

      {name, %{count: len, spectators: spectators}}
    end
  end

  defp schedule_cleanup do
    Process.send_after(self(), :cleanup, :timer.hours(2))
  end

  @spec player_left(String.t(), String.t(), [{String.t(), {:ets.tab(), integer}}], :ets.tab()) ::
          any()
  defp player_left(_group_name, _player_name, [], _tid) do
    # empty list, do nothing
    :noop
  end

  defp player_left(group_name, player_name, [{_, {group_tid, _}}], tid) do
    :ets.delete(group_tid, player_name)

    if :ets.info(group_tid, :size) == 0 do
      Logger.debug(["Group ", group_name, " is empty, deleting"])
      :ets.delete(tid, group_name)
      :ets.delete(group_tid)
    else
      players =
        :ets.tab2list(group_tid)
        |> Enum.map(fn {player_name, folder} ->
          [player_name, folder]
        end)

      ElixirBackendWeb.Endpoint.broadcast("room:#{group_name}", "player_left", %{
        "body" => players
      })
    end
  end
end
