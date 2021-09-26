defmodule ElixirBackendWeb.Router do
  use ElixirBackendWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Only valid "kinds" are chips, viruses, and ncps at present
  scope "/fetch", ElixirBackendWeb do
    pipe_through :api

    # see what folder groups are currently open
    get "/groups", GroupsController, :index

    # get all chips/viruses/ncps
    get "/:kind", LibObjController, :fetch

    # get all chips/viruses/ncps except "campaign specific" ones
    get "/:kind/default", LibObjController, :fetch_no_custom

  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  #if Mix.env() in [:dev, :test] do
  #  import Phoenix.LiveDashboard.Router
  #
  #  scope "/" do
  #    pipe_through :browser
  #    live_dashboard "/dashboard", metrics: ElixirBackendWeb.Telemetry
  #  end
  #end
end
