defmodule UselessMachineWeb.RouteHandler do
  import Plug.Conn
  # import Phoenix.Controller, only: [redirect: 2]

  require Logger

  def init(opts), do: opts

  def call(conn, _opts) do
    Logger.info("In RouteHandler, request path is #{conn.request_path}")
    conn
      |> handle_conn()
  end

  def handle_conn(conn) do
    this_machine = System.get_env("FLY_MACHINE_ID")
    path = conn.request_path |> Path.basename()

    # [path] = conn.path_info
    #path_info: ["machine", "local"],

    Logger.info("in RouteHandler, this_machine is #{this_machine} and path is #{path}")
    # Using a `machine` part to the path to make it easy to tell that apart from health, assets,
    # live_reload, etc. etc. in path

    case path do

      ^this_machine ->
        Logger.info("RouteHandler: Requested Machine is indeed this Machine so carry on.")
        # Allow the request to continue to the LiveView
        conn

      requested_machine ->
          Logger.info("RouteHandler: Requested #{requested_machine} but this is #{this_machine}")
          # Redirect with a 301 and custom header
          conn
          |> put_resp_header("fly-replay", "instance=#{requested_machine}")
          |> send_resp(301, "")
          |> halt()

      something_else -> Logger.info("in RouteHandler, path was an unexpected #{something_else}")
          conn


        # conn |> fetch_session(_opts)
        #     |> put_session(:live_socket_id, "machine_path:#{path}")

    end


  end
end
