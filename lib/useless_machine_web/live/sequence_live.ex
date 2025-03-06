defmodule UselessMachineWeb.SequenceLive do
  use UselessMachineWeb, :live_view
  alias UselessMachineWeb.AsciiArt
  require Logger

  # Define module attributes
  @initial_dwell 2000 # milliseconds before animation starts
  @display_time 500 # milliseconds between messages
  @ascii_dir "priv/static/ascii"


  def mount(_params, _session, socket) do
    # Start the sequence on mount
    if connected?(socket) do
      send(self(), :start_sequence)
    end

    {:ok, assign(socket,
      current_file: nil,
      text_index: 0,
      sequence_complete: false,
      files: get_ascii_files(@ascii_dir),
      num_files: length(get_ascii_files(@ascii_dir))
    ),
      layout: false}
  end

  def render(assigns) do
    if (assigns.sequence_complete == false) do
      ~H"""
      <div class="container mx-auto p-8 max-w-lg h-lvh bg-[#240000]">
        <h1 class="text-2xl font-bold mb-4">You started a Fly Machine</h1>

        <div class="flex items-center justify-center">
          <AsciiArt.ascii_art file_path={@current_file} bg_class="bg-[#240000]"/>
        </div>

        <div class="mt-4 text-sm text-gray-600">
          <%= if @sequence_complete do %>
            <p>Sequence complete. Shutting down...</p>
          <% else %>
            <p>Displaying message <%= @text_index %> of <%= @num_files %></p>
          <% end %>
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
    Process.send_after(self(), :next_text, @initial_dwell)
    {:noreply, assign(socket, current_file: Enum.at(socket.assigns.files, 0), text_index: 1)}
  end
  # current_file: Enum.at(socket.assigns.files, 0),

  def handle_info(:next_text, socket) do
    next_index = socket.assigns.text_index
    files = socket.assigns.files
    num_files = socket.assigns.num_files

    if next_index < (num_files - 1) do
      # Display the next text and schedule the following one
      Process.send_after(self(), :next_text, @display_time)
      {:noreply, assign(socket,
        current_file: Enum.at(files, next_index),
        text_index: next_index + 1
      )}
    else
      # All texts displayed, prepare for shutdown
      Process.send_after(self(), :shutdown_app, 10)
      {:noreply, assign(socket, sequence_complete: true)}
    end
  end

  def handle_info(:shutdown_app, socket) do
    # Log shutdown message
    Logger.info("Sequence complete, shutting down application")
    {:noreply, assign(socket, sequence_complete: true)}
    # Schedule the actual system halt with a small delay
    # to allow the final message to be rendered
    # Task.Supervisor.start_child(UselessMachine.TaskSupervisor, fn ->
    #   Process.sleep(500)
    #   System.stop(0)
    # end)

    {:noreply, socket}
  end

  # Helpers
  def get_ascii_files(dir) do
    with {:ok, files} <- File.ls(dir) do
      files
      |> Enum.sort
      |> Enum.map(fn file -> Path.join([dir, file]) end)
    end
  end

end
