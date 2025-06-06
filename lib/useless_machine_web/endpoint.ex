defmodule UselessMachineWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :useless_machine
  import Plug.Conn

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_useless_machine_key",
    signing_salt: "9Zu2b4iy",
    same_site: "Lax"
  ]

  # https://peterullrich.com/request-routing-and-sticky-sessions-in-phoenix-on-fly
  def call(conn, opts) do
    case UselessMachineWeb.RouteHandler.call(conn, opts) do
      %Plug.Conn{halted: true} = conn -> conn # if it was redirected, it gets halted in the plug; leave it halted
      conn -> super(conn, opts) # if the plug passed it through, now send it to the default version of call/2
    end
  end

  socket "/live", Phoenix.LiveView.Socket,
    websocket: [connect_info: [session: @session_options]],
    longpoll: [connect_info: [session: @session_options]]

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :useless_machine,
    gzip: false,
    only: UselessMachineWeb.static_paths()

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :useless_machine
  end

  plug Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug UselessMachineWeb.Router
end
