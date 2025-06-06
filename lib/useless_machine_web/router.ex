defmodule UselessMachineWeb.Router do
  use UselessMachineWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {UselessMachineWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  #  plug :fly_region_header_to_session


  pipeline :localhost_only do
    plug UselessMachineWeb.LocalhostOnly
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Localhost-only route for health check ()
  scope "/health", UselessMachineWeb do
    pipe_through [:api, :localhost_only]
    get "/", HealthCheckController, :check
  end

  # Enable LiveDashboard in development
  if Application.compile_env(:useless_machine, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev", UselessMachineWeb do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: UselessMachineWeb.Telemetry
    end
  end

  scope "/bye", UselessMachineWeb do
    pipe_through :browser
    get "/", PageController, :bye
  end

  scope "/", UselessMachineWeb do
    pipe_through :browser
    live "/machine", SequenceLive
  end

  # This gets where the request came from (unused for the moment)
  def fly_region_header_to_session(conn, _opts) do
    header = get_req_header(conn, "fly-region")
    conn |> put_session(:fly_region, header)
  end

end
