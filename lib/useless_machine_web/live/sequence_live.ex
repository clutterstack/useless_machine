defmodule UselessMachineWeb.SequenceLive do
  use UselessMachineWeb, :live_view
  require Logger

  # Define module attributes
  @texts [
    "First message in the sequence",
    "Second message - transitions automatically",
    "Third in our series of messages",
    "Last message before shutdown"
  ]
  @display_time 3000 # milliseconds between messages

  def mount(_params, _session, socket) do
    # Start the sequence on mount
    if connected?(socket) do
      send(self(), :start_sequence)
    end

    {:ok, assign(socket,
      current_text: nil,
      text_index: 0,
      sequence_complete: false,
      texts: @texts
    )}
  end

  def render(assigns) do
    ~H"""
    <div class="container mx-auto p-8 max-w-md">
      <h1 class="text-2xl font-bold mb-4">Text Sequence Demo</h1>

      <div class="bg-gray-100 p-4 rounded-lg min-h-[100px] flex items-center justify-center">
        <p class="text-xl text-center transition-opacity duration-500 ease-in-out">
          <%= @current_text %>
        </p>
      </div>

      <div class="mt-4 text-sm text-gray-600">
        <%= if @sequence_complete do %>
          <p>Sequence complete. Shutting down in 3 seconds...</p>
        <% else %>
          <p>Displaying message <%= @text_index %> of <%= length(@texts) %></p>
        <% end %>
      </div>
    </div>
    """
  end

  def handle_info(:start_sequence, socket) do
    # Display the first text and schedule the next one
    Process.send_after(self(), :next_text, @display_time)
    {:noreply, assign(socket, current_text: Enum.at(@texts, 0), text_index: 1)}
  end

  def handle_info(:next_text, socket) do
    next_index = socket.assigns.text_index

    if next_index < length(@texts) do
      # Display the next text and schedule the following one
      Process.send_after(self(), :next_text, @display_time)
      {:noreply, assign(socket,
        current_text: Enum.at(@texts, next_index),
        text_index: next_index + 1
      )}
    else
      # All texts displayed, prepare for shutdown
      Process.send_after(self(), :shutdown_app, 3000)
      {:noreply, assign(socket, sequence_complete: true)}
    end
  end

  def handle_info(:shutdown_app, socket) do
    # Log shutdown message
    Logger.info("Sequence complete, shutting down application")

    # Schedule the actual system halt with a small delay
    # to allow the final message to be rendered
    Task.Supervisor.start_child(UselessMachine.TaskSupervisor, fn ->
      Process.sleep(500)
      System.stop(0)
    end)

    {:noreply, socket}
  end
end
