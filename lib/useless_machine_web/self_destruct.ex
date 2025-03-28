defmodule UselessMachine.SelfDestruct do
  use GenServer
  require Logger

  @shutoff_after :timer.seconds(20000)

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
    Logger.info("About to broadcast to app:status; machine_id is #{machine_id}")

    Phoenix.PubSub.broadcast(WhereMachines.PubSub, "app:status", {:app_started, machine_id})

    Logger.info("Broadcast sent to app:status")
    # :timer.sleep(100) # Small buffer to ensure everything is ready
    # Logger.info("Starting self_destruct genserver. About to broadcast to app:status; :machine_id is #{Application.get_env(:useless_machine, :machine_id)}")
    # Phoenix.PubSub.broadcast(WhereMachines.PubSub, "app:status", {:app_started, Application.get_env(:useless_machine, :machine_id)})
    Logger.info("Setting self-destruct timer for #{@shutoff_after} ms")
    schedule_shutoff()
    {:ok, %{}}
  end

  # Use Task.Supervisor for a controlled shutdown, though in this case
  # simply issuing System.stop(0) seems just as appropriate
  def handle_info(:shutoff, _state) do
    Logger.debug("reached TTL; shutting down")
    Task.Supervisor.start_child(UselessMachine.TaskSupervisor, fn ->
      System.stop(0)
    end)
  end

  defp schedule_shutoff do
    Process.send_after(self(), :shutoff, @shutoff_after)
  end

end
