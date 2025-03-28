defmodule UselessMachineWeb.PageController do
  use UselessMachineWeb, :controller

  import Phoenix.LiveView.Controller
  require Logger

  # def home(conn, _params) do
  #   this_machine = System.get_env("FLY_MACHINE_ID") || "nomachine"
  #   Logger.info("Hit root url. Redirecting to /#{this_machine} ")
  #   conn |> redirect(to: "/#{this_machine}")
  # end

  # def direct_to_machine(conn, _params) do
  #   this_machine = System.get_env("FLY_MACHINE_ID")
  #   Logger.info("this_machine: #{mach_id}")
  #   live_render(conn, UselessMachineWeb.SequenceLive)
  # end

  def direct_to_machine(conn, %{"mach_id" => mach_id}) do
    if mach_id == System.get_env("FLY_MACHINE_ID") do
      Logger.info("mach id #{mach_id} matched #{System.get_env("FLY_MACHINE_ID")}")
      live_render(conn, UselessMachineWeb.SequenceLive)
    else
      Logger.info("No match: mach_id #{mach_id} did NOT match #{System.get_env("FLY_MACHINE_ID")}")
      conn
      |> send_resp(404, "Not found")
    end
  end

  def replay_to_machine(conn, %{"mach_id" => mach_id}) do
    this_machine = System.get_env("FLY_MACHINE_ID")
    Logger.info("this_machine: #{mach_id}")
    if mach_id == this_machine do
      Logger.info("Already on the right Machine")
      live_render(conn, UselessMachineWeb.SequenceLive)
    else
      Logger.info("Wrong Machine. This Machine is #{this_machine}. Requested #{mach_id}.")
      Logger.info("Responding with fly-replay header")
      # render(conn, :home, machine: mach_id, this_machine: this_machine)
      conn
      |> put_resp_header("fly-replay", "instance=#{mach_id}")
      |> send_resp(307, "")
    end
  end
end
