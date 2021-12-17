# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
import Config

# database_url =
#  System.get_env("DATABASE_URL") ||
#    raise """
#    environment variable DATABASE_URL is missing.
#    For example: ecto://USER:PASS@HOST/DATABASE
#    """

config :elixir_backend, ElixirBackend.Repo,
  # ssl: true,
  # url: database_url,
  username: "postgres",
  password: "postgres",
  database: "default",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: false,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

secret_key_base = "RANDOM_STRING_HERE"

config :elixir_backend, ElixirBackendWeb.Endpoint,
  http: [
    port: String.to_integer(System.get_env("PORT") || "4000"),
    transport_options: [socket_opts: [:inet6]]
  ],
  secret_key_base: secret_key_base

# ## Using releases (Elixir v1.9+)
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start each relevant endpoint:
#
config :elixir_backend, ElixirBackendWeb.Endpoint, server: true
#
# Then you can assemble a release by calling `mix release`.
# See `mix help release` for more information.
