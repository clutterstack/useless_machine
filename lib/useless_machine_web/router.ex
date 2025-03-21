defmodule UselessMachineWeb.Router do
  use UselessMachineWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fly_region_header_to_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {UselessMachineWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", UselessMachineWeb do
    pipe_through :browser
    get "/", PageController, :home
    live "/:mach_id", SequenceLive
    live "/nomachine", SequenceLive
    get "/machine/:mach_id", PageController, :replay_to_machine
  end

  # Other scopes may use custom stacks.
  # scope "/api", UselessMachineWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard in development
  if Application.compile_env(:useless_machine, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: UselessMachineWeb.Telemetry
    end
  end

  def fly_region_header_to_session(conn, _opts) do
    header = get_req_header(conn, "fly-region")
    conn |> put_session(:fly_region, header)
  end

end
