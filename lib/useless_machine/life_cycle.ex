defmodule UselessMachine.LifeCycle do
  use GenServer
  require Logger

  @shutoff_after :timer.seconds(6000)
  @poll_interval 200 # milliseconds
  @max_attempts 30   # 6 seconds max

  ## Client
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [])
  end

  ## Server
  def init(_) do
    machine_id = System.get_env("FLY_MACHINE_ID")
    # Start polling immediately
    send(self(), :check_readiness)
    Logger.debug("Starting self_destruct genserver on Machine #{machine_id}")

    Logger.debug("Setting self-destruct timer for #{@shutoff_after} ms")
    schedule_shutoff()
    {:ok, %{attempts: 0}}
  end

  # Checking an internal endpoint to see if Bandit is up and running
  def handle_info(:check_readiness, %{attempts: attempts} = state) do
    if attempts < @max_attempts do
      case check_health_endpoint() do
        :ok ->
          Logger.info("Application ready to serve requests")
          UselessMachine.StatusClient.send_status("listening")
          {:noreply, %{state | attempts: 0}}

        :error ->
          Process.send_after(self(), :check_readiness, @poll_interval)
          {:noreply, %{state | attempts: attempts + 1}}
      end
    else
      Logger.error("Failed to confirm application readiness after #{@max_attempts} attempts")
      {:noreply, %{state | attempts: 0}}
    end
  end

  def handle_info(:check_readiness, state) do
    Logger.info(":check_readiness received with state #{inspect state}")
  end

  # Use Task.Supervisor for a controlled shutdown
  def handle_info(:shutoff, _state) do
    Logger.debug("Reached TTL; sending stopping status and shutting down")

    # Send "stopping" status to where_machines
    UselessMachine.StatusClient.send_status("stopping")

    # Give some time for the HTTP request to complete before shutting down
    :timer.sleep(400)

    Task.Supervisor.start_child(UselessMachine.TaskSupervisor, fn ->
      System.stop(0)
    end)

    {:noreply, %{}}
  end

  defp check_health_endpoint do
    port = System.get_env("PORT") || "4040"
    Logger.debug("check_health_endpoint about to request health at http://localhost:#{port}/health")
    case Req.get("http://localhost:#{port}/health", receive_timeout: 50) do
      {:ok, %{status: 200}} -> :ok
      _ -> :error
    end
  end

  defp schedule_shutoff do
    Process.send_after(self(), :shutoff, @shutoff_after)
  end
end
