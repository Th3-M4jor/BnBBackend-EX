import Config

config :elixir_backend,
  bot_node_name: :foo@bar

config :elixir_backend, ElixirBackendWeb.Endpoint,
  url: [host: "example.com", port: 4000],
  cache_static_manifest: "priv/static/cache_manifest.json"

# Do not print debug messages in production
config :logger, level: :warn


import_config "prod.secret.exs"
