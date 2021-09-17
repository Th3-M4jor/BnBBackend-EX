defmodule ElixirBackendWeb.TestSocket do
  @behaviour Phoenix.Socket.Transport

  require Logger

  def child_spec(opts) do
    # We won't spawn any process, so let's return a dummy task

    Logger.debug(["Generating child spec\n", inspect(opts, pretty: true)])

    %{id: Task, start: {Task, :start_link, [fn -> :ok end]}, restart: :transient}
  end

  def connect(map) do
    Logger.debug([
      "connecting to test socket\n",
      inspect(map, pretty: true)
    ])

    # Callback to retrieve relevant data from the connection.
    # The map contains options, params, transport and endpoint keys.
    {:ok, %{}}
  end

  def init(state) do
    Logger.debug([
      "initializing test socket\n",
      inspect(state, pretty: true)
    ])
    # Now we are effectively inside the process that maintains the socket.
    {:ok, state}
  end

  def handle_in({text, opts}, state) do

    Logger.debug([
      "handling in test socket\n",
      inspect(text, pretty: true),
      inspect(opts, pretty: true),
    ])

    {:reply, :ok, {:text, text}, state}
  end

  def handle_info(_, state) do
    {:ok, state}
  end

  def terminate(reason, state) do
    Logger.debug(["Socket closed\n",
      inspect(reason, pretty: true),
      inspect(state, pretty: true)
    ])
    :ok
  end
end
