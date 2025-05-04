defmodule UselessMachineWeb.CheckMachine do
  import Phoenix.LiveView

  require Logger

  # def on_mount(:default, %{"mach_id" => requested_machine }, _session, socket) do
  #   if requested_machine == System.get_env("FLY_MACHINE_ID") do
  #     Logger.info("In CheckMachine module. This Machine is the requested Machine.")
  #     {:cont, socket}
  #   else
  #     Logger.info("In CheckMachine module. Wrong Machine. Redirecting.")
  #     # {:halt, redirect(socket, to: "/redirect/#{requested_machine}")}
  #     {:halt, redirect(socket, external: "https://useless-machine-fly.dev/#{requested_machine}")}
  #   end
  # end

  def on_mount(:default, %{"mach_id" => path } = params, _session, socket) do
    # path = socket.assigns[:path] || extract_path_from_connect_params(socket)
    Logger.info("In CheckMachine.on_mount, params is #{inspect params, pretty: true}")
    # Logger.info("In CheckMachine.on_mount, socket.private is #{inspect socket.private, pretty: true}")
    cond do
      needs_fly_replay?(path) ->
        Logger.info("In CheckMachine module. Wrong Machine. Redirecting to #{path}.")
        # {:halt, redirect(socket, to: "/redirect/#{requested_machine}")}

        socket =
          socket |> redirect(to: "/#{path}")
        # Halt the mount process with a redirect
        {:halt, socket}
      true ->
        Logger.info("In CheckMachine module. This Machine is the requested Machine.")
        {:cont, socket}
    end
  end


  defp needs_fly_replay?(path) do
    if path == System.get_env("FLY_MACHINE_ID") do
      false
    else
      true
    end
  end


  # Helper to extract path from connect_params (available during reconnections)
  defp extract_path_from_connect_params(socket) do
    Logger.info("In extract_path_from_connect_params.")
    case socket.private do
      %{connect_params: %{"_live_referer" => referer}} ->
        URI.parse(referer).path |> String.trim_leading("/") |> String.split("/")
      _ ->
        []
    end
  end



end
