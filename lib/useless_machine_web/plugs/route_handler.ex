defmodule UselessMachineWeb.RouteHandler do
  use Plug.Builder # saves writing explicit init and stuff
  import Plug.Conn

  require Logger

  @cookie_key "fly-machine-id"
  @cookie_ttl 5 * 60 * 1000 # 5 minutes; Machines shut down in one minute anyway

  def call(conn, opts) do
    conn
    |> fetch_query_params()
    |> fetch_cookies()
    |> handle_conn(opts)
# might want conn.request_path?
  end


  def handle_conn(%Plug.Conn{params: params} = conn, _opts) do
    machine_id = System.get_env("FLY_MACHINE_ID") #Application.get_env(:chat, :fly_machine_id)
    param_id = Map.get(params, "instance")
    cookie_id = Map.get(conn.req_cookies, @cookie_key, machine_id)
    # Logger.info("In RouteHandler, request path is #{conn.request_path}")
    # Logger.info("In RouteHandler, param_id is #{param_id}")
    # Logger.info("In RouteHandler, cookie_id is #{cookie_id}")



    cond do
      param_id && param_id == "health" ->
        Logger.info("Health endpoint. Carry on as normal.")
        conn

      param_id && param_id == machine_id ->
        Logger.info("Correct machine based on parameter #{param_id}. Set cookie and let pass.")
        put_resp_cookie(conn, @cookie_key, machine_id, max_age: @cookie_ttl)

      param_id && param_id != machine_id ->
        Logger.info("Incorrect machine #{machine_id} based on parameter #{param_id}. Redirect.")
        redirect_to_machine(conn, param_id)

      cookie_id && cookie_id == machine_id ->
        Logger.info("Correct machine based on cookie #{cookie_id}. Let pass.")
        # Logger.info("(request path is #{conn.request_path})")
        conn

      cookie_id && cookie_id != machine_id ->
        Logger.info("Incorrect machine #{machine_id} based on cookie #{cookie_id}. Redirect.")
        # Logger.info("(request path is #{conn.request_path})")

        redirect_to_machine(conn, cookie_id)

      true ->
        Logger.info("No parameter or cookie. Let pass.")
        conn
    end
  end

  defp redirect_to_machine(conn, requested_machine) do
    conn
    |> put_resp_header("fly-replay", "instance=#{requested_machine}")
    |> put_resp_header("fly-replay-cache", "useless-machine.fly.dev/machine?instance=#{requested_machine}") # this doesn't work since no wildcard
    |> put_resp_header("fly-replay-cache-ttl-secs", "60") # moot, see prev line
    |> put_status(307)
    # |> Phoenix.Controller.text("redirecting...")
    |> halt()
  end

end
