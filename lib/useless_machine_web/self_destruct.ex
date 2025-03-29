defmodule UselessMachine.SelfDestruct do
  use GenServer
  require Logger

  @shutoff_after :timer.seconds(2000)

  ## Client
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  ## Server
  def init(_) do
    machine_id = System.get_env("FLY_MACHINE_ID")
    node_name = Node.self()
    connected_nodes = Node.list()

    Logger.info("Starting self_destruct genserver on node #{node_name}. Connected nodes: #{inspect connected_nodes}")
    Logger.info("Machine ID is #{machine_id}")

    # Send "started" status to where_machines via HTTP
    UselessMachine.StatusClient.send_status("started")

    Logger.info("Setting self-destruct timer for #{@shutoff_after} ms")
    schedule_shutoff()
    {:ok, %{}}
  end

  # Use Task.Supervisor for a controlled shutdown
  def handle_info(:shutoff, _state) do
    Logger.debug("Reached TTL; sending stopping status and shutting down")

    # Send "stopping" status to where_machines
    UselessMachine.StatusClient.send_status("stopping")

    # Give some time for the HTTP request to complete before shutting down
    :timer.sleep(2000)

    Task.Supervisor.start_child(UselessMachine.TaskSupervisor, fn ->
      System.stop(0)
    end)

    {:noreply, %{}}
  end

  defp schedule_shutoff do
    Process.send_after(self(), :shutoff, @shutoff_after)
  end
end
