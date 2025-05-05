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

  #     plug :fly_region_header_to_session


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

    # scope "/local", UselessMachineWeb do
    #   pipe_through [:browser, UselessMachineWeb.RouteHandler]
    #   live "/", SequenceLive
    # end

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
    #If there are no regular web requests defined under a live session, then the pipe_through checks are not necessary.
    # https://hexdocs.pm/phoenix_live_view/security-model.html
    # EXCEPT that I can't do fly-replay without getting into a plug
    # pipe_through [:browser, UselessMachineWeb.RouteHandler]
    pipe_through :browser

    # live_session :default, on_mount: UselessMachineWeb.CheckMachine do
      live "/", SequenceLive

    # end
    # get "/machine/:mach_id", PageController, :direct_to_machine
  end

  # This gets where the request came from
  def fly_region_header_to_session(conn, _opts) do
    header = get_req_header(conn, "fly-region")
    conn |> put_session(:fly_region, header)
  end

  def get_mach_id do
    System.get_env("FLY_MACHINE_ID")
  end


end
