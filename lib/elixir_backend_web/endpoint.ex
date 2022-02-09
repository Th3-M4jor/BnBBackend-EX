defmodule ElixirBackendWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :elixir_backend

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_elixir_backend_key",
    signing_salt: "/4xfEf+4"
  ]

  socket "/socket", ElixirBackendWeb.UserSocket,
    websocket: true,
    longpoll: false

  # socket "/socket/test", ElixirBackendWeb.TestSocket, websocket: [path: "/"], longpoll: false

  # socket "/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]]

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug ElixirBackendWeb.Router
end
