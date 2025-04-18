defmodule UselessMachineWeb.HealthCheckController do
  use UselessMachineWeb, :controller

  # If Bandit is up and running the health-check route will respond.
  def check(conn, _params) do
    json(conn, %{status: "ok"})
  end
end
