defmodule ElixirBackend.Repo do
  use Ecto.Repo,
    otp_app: :elixir_backend,
    adapter: Ecto.Adapters.Postgres,
    read_only: true
end
