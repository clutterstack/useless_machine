defmodule UselessMachineWeb.SequenceLive do
  use UselessMachineWeb, :live_view
  alias UselessMachineWeb.AsciiArt
  require Logger

  # Define module attributes
  @initial_dwell 2000 # milliseconds before animation starts
  @display_time 2000 # milliseconds between messages
  @ascii_dir "ascii"

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
      really_done: false
    )}
  end

  def render(assigns) do
    if (assigns.sequence_complete == false) do
      ~H"""
      <div class="container mx-auto p-8 max-w-lg h-lvh bg-[#240000]">
        <h1 class="text-2xl font-bold mb-4 text-gray-200">You started a Fly Machine in <%= @fly_region %></h1>
        <div class="text-gray-200">This is Machine {get_mach_id()}</div>
        <div class="flex items-center justify-center">
          <AsciiArt.ascii_art file_path={@current_file} bg_class="bg-[#240000]"/>
          <div class="h-full bg-black"> </div>
        </div>

        <div class="mt-4 text-sm text-gray-200">
          <p>Displaying message <%= @text_index %> of <%= @num_files %></p>
        </div>
      </div>
      """
    else
      ~H"""
      <div class="container-full mx-0 w-100 h-lvh bg-black">
        <div class="container mx-auto p-8 max-w-lg">
          <h1 class="text-2xl font-bold mb-4">Bye</h1>
          <div class="flex items-center justify-center">
            <AsciiArt.ascii_art file_path={@current_file} />
          </div>
        </div>
      </div>

      """
    end
  end

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
    text_index < (num_files - 1) ->
      # Display the next text and schedule the following one
      Process.send_after(self(), :next_text, @display_time)
      {:noreply, assign(socket,
        current_file: Enum.at(files, text_index),
        text_index: text_index + 1
      )}
    text_index == (num_files - 1) ->
      # All texts displayed, prepare for shutdown
      Logger.debug("All texts displayed, prepare for shutdown")
      Process.send_after(self(), :next_text, 10)
      {:noreply, assign(socket,
        current_file: Enum.at(files, text_index),
        text_index: text_index + 1,
        sequence_complete: true
        )}
    true ->
      Logger.debug("No more files. Shutting down.")
      Logger.debug("The current_file assign is #{socket.assigns.current_file}")
      Process.send_after(self(), :shutdown_app, 10)
      {:noreply, socket}
    end
  end

  # assign(socket, really_done: true)

  def handle_info(:shutdown_app, socket) do
    # Log shutdown message
    Logger.info("Sequence complete, shutting down application")
    # Stop system
    Task.Supervisor.start_child(UselessMachine.TaskSupervisor, fn ->
      System.stop(0)
    end)

    {:noreply, socket}
  end

  # Helpers
  # def get_ascii_files(dir) do
  #   IO.inspect(dir, label: "dir passed to get_ascii_files")
  #   File.ls(dir) |> dbg
  #   with {:ok, files} <- File.ls(dir) do
  #     files
  #     |> Enum.sort
  #     |> Enum.map(fn file -> Path.join([dir, file]) end)
  #   end
  # end

  # def get_static_files(dir) do
  #   priv_dir = :code.priv_dir(:useless_machine)
  #   full_path = Path.join([priv_dir, "static", dir])
  #   |> dbg
  #   File.ls(full_path) |> dbg
  #   case File.ls(full_path) do
  #     {:ok, files} ->
  #       files
  #       |> Enum.sort
  #       |> Enum.map(fn file -> Path.join([dir, file]) end)
  #     {:error, reason} -> {:error, reason}
  #   end
  # end

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
