defmodule UselessMachine.StatusClient do
  @moduledoc """
  Client for sending status updates to the where_machines application
  """
  require Logger

  @doc """
  Send a status update to the where_machines application.
  Status should be one of:
  - "started" - Machine has started up
  - "stopping" - Machine is shutting down
  """
  def send_status(status) when status in ["started", "stopping"] do
    machine_id = System.get_env("FLY_MACHINE_ID") || "unknown"
    region = System.get_env("FLY_REGION") || "unknown"

    payload = %{
      machine_id: machine_id,
      region: region,
      status: status,
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601()
    }

    # Use a Task to avoid blocking
    Task.start(fn -> do_send_status(payload) end)
  end

  defp do_send_status(payload) do

    url = Application.get_env(:useless_machine, :where_machines_url)
    options = [
      {:timeout, Application.get_env(:useless_machine, :http_timeout, 5000)},
      {:connect_timeout, Application.get_env(:useless_machine, :http_connect_timeout, 3000)}
    ]
    Logger.info("Sending status update to where_machines at #{inspect url}: #{inspect(payload)}")


    try do
      Req.post!(
        url,
        json: payload,
        connect_options: [timeout: options[:connect_timeout]],
        receive_timeout: options[:timeout]
      ) |> dbg
      Logger.info("Status update sent successfully")
      :ok
    rescue
      e ->
        Logger.error("Exception when sending status update: #{inspect(e)}")
        {:error, :exception}
    end
  end
end
