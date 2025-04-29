defmodule UselessMachineWeb.CheckMachine do
  import Phoenix.LiveView

  require Logger

  def on_mount(:default, %{"mach_id" => requested_machine }, _session, socket) do
    if requested_machine == System.get_env("FLY_MACHINE_ID") do
      Logger.info("In CheckMachine module. This Machine is the requested Machine.")
      {:cont, socket}
    else
      Logger.info("In CheckMachine module. Wrong Machine. Redirecting.")
      # {:halt, redirect(socket, to: "/redirect/#{requested_machine}")}
      {:halt, redirect(socket, external: "https://useless-machine-fly.dev/#{requested_machine}")}
    end
  end

end
