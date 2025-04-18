defmodule UselessMachineWeb.SequenceLive do
  use UselessMachineWeb, :live_view
  alias UselessMachineWeb.AsciiArt
  require Logger

  # Define module attributes
  @initial_dwell 1400 # milliseconds before animation starts
  @display_time 100 # milliseconds between messages, usually
  @hang_fire 650 # pause before pushing button
  @button_press 100 # pushing button
  @ascii_dir "ascii"
  @button_frame 6 # the frame at which the button is depressed, turning off the lights
  @container_classes "container my-8 mx-auto p-8 max-w-xl rounded-xl p-4 border-2 border-neutral-600 font-mono"

  def mount(_params, %{"fly_region" => fly_region}, socket) do
    # Start the sequence on mount
    if connected?(socket) do
      Logger.info("fly_region: #{inspect fly_region}")
      send(self(), :start_sequence)
    end

    {:ok, assign(socket,
      fly_region: fly_region,
      current_file: nil,
      text_index: 0,
      file_path: nil,
      sequence_complete: false,
      files: get_static_files(@ascii_dir),
      num_files: length(get_static_files(@ascii_dir)),
      light_on: true,
      container_classes: @container_classes,
      frame_delay: @initial_dwell
    )}
  end

  # amber: text-[#ffb700]
  def render(assigns) do
    if (assigns.light_on) do
      ~H"""
      <div class={[@container_classes, "bg-[#240000] text-red-600"]}>
        <h1 class="text-2xl font-bold mb-4 ">You started a Useless Machine</h1>
        <div>This is Fly Machine {get_mach_id()} in <%= @fly_region %></div>
        <div class="flex flex-col items-center justify-center">
          <AsciiArt.ascii_art file_path={@current_file} />
        </div>
      </div>
      """
    else
      ~H"""
      <div class={[@container_classes, "text-slate-500"]}>
        <h1 class="text-2xl font-bold mb-4">Machine self-destructing</h1>
        <div class={@sequence_complete && "text-green-200"}><.link href="https://where.fly.dev">Back to where.fly.dev</.link></div>
        <div class="flex flex-col items-center justify-center">
          <AsciiArt.ascii_art file_path={@current_file} />
        </div>
      </div>
      """
    end
  end

  # <div class="mt-4 text-sm text-gray-200">
  # <p>Displaying message <%= @text_index %> of <%= @num_files %></p>
# </div>

  def handle_info(:start_sequence, socket) do
    # Display the first text and schedule the next one
    Logger.debug("Starting sequence with initial_dwell #{@initial_dwell}")
    Process.send_after(self(), :next_text, @initial_dwell)
    {:noreply, assign(socket, current_file: Enum.at(socket.assigns.files, 0), text_index: 1)}
  end
  # current_file: Enum.at(socket.assigns.files, 0),

  def handle_info(:next_text, socket) do
    text_index = socket.assigns.text_index
    files = socket.assigns.files
    num_files = socket.assigns.num_files

    cond do
      text_index < (@button_frame - 1) ->
        Logger.debug("Displaying frame for index #{text_index}. @light_on? #{inspect socket.assigns.light_on}")
      # Display the next text and schedule the following one
        Process.send_after(self(), :next_text, @display_time)
        {:noreply, assign(socket,
          current_file: Enum.at(files, text_index),
          text_index: text_index + 1
        )}
      text_index == (@button_frame - 1) ->
        Logger.debug("Displaying frame for index #{text_index}. @light_on? #{inspect socket.assigns.light_on}")
      # Display the next text and schedule the following one
        Process.send_after(self(), :next_text, @hang_fire)
        {:noreply, assign(socket,
          current_file: Enum.at(files, text_index),
          text_index: text_index + 1
        )}
      text_index == @button_frame ->
        Logger.debug("Displaying frame for index #{text_index}. @light_on? #{inspect socket.assigns.light_on}")
        # Display the next text and schedule the following one
        Process.send_after(self(), :next_text, @button_press)
        {:noreply, assign(socket,
          current_file: Enum.at(files, text_index),
          text_index: text_index + 1
        )}
      text_index == @button_frame + 1 ->
        Logger.debug("Displaying frame for index #{text_index}. @light_on? #{inspect socket.assigns.light_on}")
        # Display the next text and schedule the following one
        Process.send_after(self(), :next_text, @button_press)
        {:noreply, assign(socket,
          current_file: Enum.at(files, text_index),
          text_index: text_index + 1,
          light_on: false
        )}
        text_index < (num_files - 1) ->
          Logger.debug("Displaying frame for index #{text_index}. @light_on? #{inspect socket.assigns.light_on}")
          # Display the next text and schedule the following one
          Process.send_after(self(), :next_text, @display_time)
          {:noreply, assign(socket,
            current_file: Enum.at(files, text_index),
            text_index: text_index + 1
          )}
      text_index == (num_files - 1) ->
        Logger.debug("Displaying frame for index #{text_index}. @light_on? #{inspect socket.assigns.light_on}")
        # All texts displayed, prepare for shutdown
        Logger.debug("All non-blank texts displayed, prepare for shutdown")
        Process.send_after(self(), :next_text, 10)
        {:noreply, assign(socket,
          current_file: Enum.at(files, text_index),
          text_index: text_index + 1,
          sequence_complete: true
        )}
    true ->
      Logger.debug("No more files. Shutting down.")
      Logger.debug("The current_file assign is #{socket.assigns.current_file}")
      # Process.send_after(self(), :shutdown_app, 10)
      {:noreply, socket}
    end
  end

  def handle_info(:shutdown_app, socket) do
    # Log shutdown message
    Logger.info("Sequence complete, shutting down application")
    # Tell where_machines app Machine is stopping.
    UselessMachine.StatusClient.send_status("stopping")
     # Give some time for the HTTP request to complete before shutting down
     :timer.sleep(2000)
    # Stop system
    Task.Supervisor.start_child(UselessMachine.TaskSupervisor, fn ->
      System.stop(0)
    end)

    {:noreply, socket}
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

  def get_mach_id() do
    System.get_env("FLY_MACHINE_ID")
  end

end
