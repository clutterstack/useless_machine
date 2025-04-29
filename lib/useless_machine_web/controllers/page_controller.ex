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

  def bye(conn, _params) do
    file = Path.join(:code.priv_dir(:useless_machine), "static/ascii/0000-14.txt")
    # static_path = Application.app_dir(:useless_machine, ["priv", "static", "ascii"])
    # static_path = Application.app_dir(:useless_machine, ["priv", "static", "ascii"])
    render(conn, :bye, file: file)
  end



  def get_static_files(dirname) do
    # Get the static path configuration
    static_path = Application.app_dir(:useless_machine, ["priv", "static", dirname])

    with {:ok, files} <- File.ls(static_path) do
      files
      # |> dbg
      |> Enum.filter(&String.ends_with?(&1, ".txt"))
      |> Enum.sort
      |> Enum.map(fn file -> Path.join([static_path, file]) end)
    else
      {:error, reason} -> {:error, reason}
    end
  end

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
    Logger.info("In page controller replay_to_machine, requested_machine is #{mach_id}")
    if mach_id == this_machine do
      Logger.info("Already on the right Machine")
      conn |> put_session(:live_socket_id, "machine_path:#{mach_id}")
           |> live_render(UselessMachineWeb.SequenceLive)
    else
      Logger.info("Wrong Machine. This Machine is #{this_machine}. Requested #{mach_id}.")
      Logger.info("Responding with fly-replay header")
      # render(conn, :home, machine: mach_id, this_machine: this_machine)
      conn
      |> put_resp_header("fly-replay", "instance=#{mach_id}")
      |> send_resp(301, "")
    end
  end
end
