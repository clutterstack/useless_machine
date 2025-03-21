defmodule UselessMachine.SelfDestruct do
  use GenServer
  require Logger

  @shutoff_after :timer.seconds(200)

  ## Client
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  ## Server
  def init(_) do
    Logger.info("Setting self-destruct timer for #{@shutoff_after} ms")
    schedule_shutoff()
    {:ok, %{}}
  end

  # Use Task.Supervisor for a controlled shutdown, though in this case
  # simply issuing System.stop(0) seems just as appropriate
  def handle_info(:shutoff, state) do
    Logger.debug("reached TTL; shutting down")
    Task.Supervisor.start_child(UselessMachine.TaskSupervisor, fn ->
      System.stop(0)
    end)
  end

  defp schedule_shutoff do
    Process.send_after(self(), :shutoff, @shutoff_after)
  end

end
