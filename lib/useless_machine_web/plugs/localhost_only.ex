defmodule UselessMachineWeb.LocalhostOnly do
  import Plug.Conn

  require Logger

  def init(opts), do: opts

  def call(conn, _opts) do
    # Get the client's IP address
    client_ip = conn.remote_ip
    Logger.debug("In LocalhostOnly, client_ip is #{inspect client_ip}")

    if is_localhost?(client_ip) do
      Logger.debug("yes, this request comes from localhost.")
      conn
    else
      Logger.warning("the healthcheck call didn't come from localhost.")
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(404, "Not found")
      |> halt()
    end
  end

  defp is_localhost?(ip) do
    case ip do
      # IPv4 localhost
      {127, _, _, _} -> true

      # IPv6 localhost
      {0, 0, 0, 0, 0, 0, 0, 1} -> true

      # IPv4-mapped IPv6 localhost check -- this is what I needed for my deployed VM
      {0, 0, 0, 0, 0, 65535, 32512, 1} -> true

      # Not localhost
      _ -> false
    end
  end
end
