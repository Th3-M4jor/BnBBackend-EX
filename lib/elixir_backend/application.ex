defmodule ElixirBackend.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      ElixirBackend.Repo,
      # Start the Telemetry supervisor
      ElixirBackendWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: ElixirBackend.PubSub},
      # Start the Endpoint (http/https)
      ElixirBackendWeb.Endpoint,
      ElixirBackend.FolderGroups,
      # Start a worker by calling: ElixirBackend.Worker.start_link(arg)
      # {ElixirBackend.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ElixirBackend.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ElixirBackendWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
