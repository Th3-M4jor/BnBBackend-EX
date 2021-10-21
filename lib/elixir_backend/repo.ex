defmodule ElixirBackend.Repo do
  use Ecto.Repo,
    otp_app: :elixir_backend,
    adapter: Ecto.Adapters.Postgres,
    read_only: true
end

defmodule ElixirBackend.CustomQuery do
  defmacro array_contains(array, value) do
    quote do
      fragment("? = ANY(?)", unquote(value), unquote(array))
    end
  end
end
