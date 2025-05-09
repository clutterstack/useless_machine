defmodule UselessMachine.StatusClient do
  @moduledoc """
  Client for sending status updates to the where_machines application
  """
  require Logger

  @doc """
  Send a status update to the where_machines application.
  Status should be one of:
  - "listening" - App is running; should be able to visit it.
  - "stopping" - Machine is shutting down
  """
  # TODO? If not successful, send to top1.of.where.internal
  # Not too worried about this, but consider: what happens if the user gets reconnected on a different
  # instance somehow? Is that likely? Is the experience weirded out anyway, if that happens? Prolly.
  def send_status(status) when status in ["listening", "stopping"] do
    machine_id = System.get_env("FLY_MACHINE_ID") || "unknown"
    region = System.get_env("FLY_REGION") || "unknown"
    payload =
      if status == "listening" do
        %{
          machine_id: machine_id,
          region: region,
          status: status,
          timestamp: DateTime.utc_now() |> DateTime.to_iso8601()
        }
      else
        %{
          machine_id: machine_id
        }
      end

    # Use a Task to avoid blocking
    Task.start(fn -> do_send_status(payload) end)
  end

  defp do_send_status(payload) do
    url = Application.get_env(:useless_machine, :where_machines_url)
    options = [
      {:timeout, Application.get_env(:useless_machine, :http_timeout, 5000)},
      {:connect_timeout, Application.get_env(:useless_machine, :http_connect_timeout, 3000)}
    ]
    Logger.info("Sending status update to #{inspect url}: #{inspect(payload)}")

    # Try the primary endpoint first
    case send_request(url, payload, options) do
      :ok ->
        Logger.info("Status update sent successfully")
        :ok
      {:error, exception} ->
        # If primary fails, try the fallback endpoint
        Logger.warning("Error from Req on status update: #{inspect(exception)}. Trying fallback endpoint.")
        try_fallback(payload, options)
    end
  end

  defp send_request(url, payload, options) do
    case Req.post(
        url,
        json: payload,
        connect_options: [
          timeout: options[:connect_timeout],
          transport_opts: [inet6: true]
        ],
        receive_timeout: options[:timeout]
    ) do
      {:ok, %Req.Response{}} -> :ok
      error -> error
    end
  end

  defp try_fallback(payload, options) do
    # Use top1.nearest.of.where.internal for fallback
    fallback_url = "http://top1.nearest.of.where.internal:4001/api/machine_status"
    Logger.info("Attempting fallback to #{fallback_url}")

    case send_request(fallback_url, payload, options) do
      :ok ->
        Logger.info("Status update sent successfully via fallback")
        :ok
      {:error, exception} ->
        Logger.error("Fallback also failed: #{inspect(exception)}")
        {:error, exception}
    end
  end
end
