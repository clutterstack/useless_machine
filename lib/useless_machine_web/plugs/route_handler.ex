defmodule UselessMachineWeb.RouteHandler do
  import Plug.Conn
  # import Phoenix.Controller, only: [redirect: 2]

  require Logger

  def init(opts), do: opts

  def call(conn, _opts) do
    this_machine = System.get_env("FLY_MACHINE_ID")
    path = conn.request_path |> Path.basename()

    Logger.info("in RouteHandler, this_machine is #{this_machine} and path is #{path}")

    case path do
      ^this_machine ->
        Logger.info("Requested #{path} is indeed this Machine so carry on.")
        # Allow the request to continue to the LiveView

        conn |> put_session(:live_socket_id, "machine_path:#{path}")
      _ ->
        Logger.info("Requested #{path} but this is #{this_machine}")
        # Redirect with a 301 and custom header
        conn
        |> put_resp_header("fly-replay", "instance=#{path}")
        |> send_resp(301, "")
        |> halt()
    end
  end
end
