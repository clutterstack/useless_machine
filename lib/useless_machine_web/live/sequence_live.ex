defmodule UselessMachineWeb.SequenceLive do
  use UselessMachineWeb, :live_view
  alias UselessMachineWeb.AsciiArt
  require Logger
  alias UselessMachine.Cities

  # Define module attributes
  @initial_dwell 2500 # milliseconds before animation starts
  @display_time 140 # milliseconds between messages, usually
  @hang_fire 650 # pause before pushing button
  @button_press 200 # pushing button
  @ascii_dir "ascii"
  @button_frame 6 # the frame at which the button is depressed, turning off the lights
  @container_classes "container relative my-8 mx-auto px-0 w-fit rounded-xl p-4 pb-0 box-border border-2 border-neutral-600 font-mono"
  @message_classes "absolute top left px-4 "
  @txt_classes "text-[7px] sm:text-[10px] font-black"

  # %{"fly_region" => fly_region}
  def mount(_params, _session, socket) do
    # Preload the ascii images from their files
    ascii_frames =
      get_static_files(@ascii_dir)
      |> Enum.map(fn file_path ->
        {file_path, File.read!(file_path)}
      end)
      |> Enum.into(%{})

    first_file = Enum.at(get_static_files(@ascii_dir), 0)
    first_content = Map.get(ascii_frames, first_file)

    # Start the sequence on mount
    if connected?(socket) do
      send(self(), :start_sequence)
    end

    fly_region = System.get_env("FLY_REGION") || "unknown"
    txt_files = get_static_files(@ascii_dir)

    {:ok, assign(socket,
      fly_region: fly_region,
      current_file: first_file,
      current_content: first_content,
      ascii_frames: ascii_frames,
      text_index: 1,
      file_path: nil,
      sequence_complete: false,
      files: txt_files,
      num_files: length(get_static_files(@ascii_dir)),
      light_on: true,
      container_classes: @container_classes,
      message_classes: @message_classes,
      txt_classes: @txt_classes,
      frame_delay: @initial_dwell,
      end_state: Application.get_env(:useless_machine, :machine_end_state),
      final_view: Application.get_env(:useless_machine, :final_view)
    )}
  end

  # amber: text-[#ffb700]
  def render(assigns) do
    if (assigns.light_on) do
      ~H"""
      <div class={[@container_classes, "bg-[#240000] text-red-500"]}>
        <div class={@message_classes}>
          <h1 class="text-xl sm:text-2xl font-bold mb-1 text-[#ffb700] h-[2lh] sm:h-auto mr-4">You started a Useless Machine</h1>
          <div>This is Fly Machine {get_mach_id()} in <%= Cities.short(@fly_region) %></div>
        </div>
        <div class="flex flex-col mt-16 sm:mt-12 items-center justify-center">
          <AsciiArt.ascii_art content={@current_content} class={@txt_classes}/>
        </div>
      </div>
      """
    else
      ~H"""
      <div class={[@container_classes, "text-slate-400"]}>
        <div class={@message_classes}>
          <h1 class="text-xl sm:text-2xl font-bold mb-1 h-[2lh] sm:h-auto">{@sequence_complete && "This Machine is no more." || "VM self-destructing"}</h1>
          <div class={[@sequence_complete && "text-green-200", "self-end"]}><.link href="https://where.fly.dev">Back to where.fly.dev</.link></div>
        </div>
        <div class="flex flex-col mt-16 sm:mt-12 items-center justify-center">
          <AsciiArt.ascii_art content={@current_content} class={@txt_classes}/>
        </div>
      </div>
      """
    end
  end

  # def terminate(_reason, socket) do
  #   IO.puts("LiveView with ID #{socket.id} is terminating.")
  #   # UselessMachineWeb.Endpoint.broadcast("machine_path:#{path}", "disconnect", %{})
  # end

  # <div class="mt-4 text-sm text-gray-200">
  # <p>Displaying message <%= @text_index %> of <%= @num_files %></p>
# </div>

  def handle_info(:start_sequence, socket) do
    # Display the first text and schedule the next one
    Logger.debug("Starting sequence with initial_dwell #{@initial_dwell}")
    Process.send_after(self(), :next_text, @initial_dwell)
    {:noreply, socket}
  end
  # current_file: Enum.at(socket.assigns.files, 0),

  def handle_info(:next_text, socket) do
    text_index = socket.assigns.text_index
    files = socket.assigns.files
    num_files = socket.assigns.num_files
    final_view = socket.assigns.final_view
    end_state = socket.assigns.end_state
    ascii_frames = socket.assigns.ascii_frames
    current_file = Enum.at(files, text_index)
    current_content = Map.get(ascii_frames, current_file)


    if text_index < num_files do
      delay = set_delay(text_index, num_files)
      Logger.debug("at text_index #{text_index}")
      Process.send_after(self(), :next_text, delay)

      cond do
        text_index == (num_files - 1) ->
          # All texts displayed, prepare for shutdown
          Logger.debug("All texts displayed, prepare for shutdown")
          {:noreply, assign(socket,
            current_file: current_file,
            current_content: current_content,
            text_index: text_index + 1,
            sequence_complete: true
          )}

        text_index == @button_frame + 1 ->
          # Display the next text and schedule the following one
          # Turn off the "light" here
          {:noreply, assign(socket,
            current_file: current_file,
            current_content: current_content,
            text_index: text_index + 1,
            light_on: false
          )}

        true ->
          # Display the next text and schedule the following one
          {:noreply, assign(socket,
            current_file: current_file,
            current_content: current_content,
            text_index: text_index + 1
          )}
      end
    else
      Logger.info("Finished sequence.")
      if end_state == "stopped" do
        Logger.info("Shutting down.")
        UselessMachine.StatusClient.send_status("stopping")
        # Start an async task to shut down the Machine, so that it won't
        # be interrupted by the redirect
        Task.Supervisor.start_child(UselessMachine.TaskSupervisor, fn ->
          # Give some time for the HTTP request to complete before shutting down
          :timer.sleep(500)
          # Stop system
          System.stop(0)
        end)
      else
          Logger.info("Keeping Machine running")
      end
      if final_view == "bye" do
        # Meanwhile send the client to a regular controller view so it doesn't try to
        # reconnect when the Machine shuts down, and
        # so it keeps showing that last frame
        Logger.info("redirecting to classic Phoenix view to close WebSockets connection")
        {:noreply, redirect(socket, to: ~p"/bye")}
      else
        Logger.info("staying in SequenceLive LiveView")
        {:noreply, socket}
      end
    end
  end

  @doc """
  Returns the number of files in the static/ascii directory based on the manifest.
  """
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

  def set_delay(text_index, num_files) do
    cond do
      text_index < (@button_frame - 1) -> @display_time
      text_index == (@button_frame - 1) -> @hang_fire
      text_index == @button_frame -> @button_press
      text_index == @button_frame + 1 -> @button_press
      text_index < (num_files - 1) -> @display_time
      text_index == (num_files - 1) -> 10
      true -> 0
    end
  end

  defp get_mach_id() do
    System.get_env("FLY_MACHINE_ID")
  end

end
