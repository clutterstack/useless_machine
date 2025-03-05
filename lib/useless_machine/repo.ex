defmodule UselessMachine.Repo do
  use Ecto.Repo,
    otp_app: :useless_machine,
    adapter: Ecto.Adapters.SQLite3
end
