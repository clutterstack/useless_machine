defmodule UselessMachineWeb.PageController do
  use UselessMachineWeb, :controller
  require Logger

  def home(conn, _params) do
    this_machine = System.get_env("FLY_MACHINE_ID") || "nomachine"
    Logger.info("Hit root url. Redirecting to /#{this_machine} ")
    conn |> redirect(to: "/#{this_machine}")
  end

  def replay_to_machine(conn, %{"mach_id" => mach_id}) do
    this_machine = System.get_env("FLY_MACHINE_ID")
    Logger.info("this_machine: #{mach_id}")
    if mach_id == this_machine do
      Logger.info("about to redirect to /#{this_machine}")
      conn |> redirect(to: "/#{this_machine}")
    else
      Logger.info("about to respond with fly-replay header")
      conn
      |> put_resp_header("fly-replay", "instance=#{mach_id}")
      |> send_resp(302, "")
    end
  end
end
