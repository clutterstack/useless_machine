import Config

# Test environment API URL
config :useless_machine,
  where_machines_url: "http://localhost:4000/api/machine_status",
  # Use shorter timeouts for faster test failures
  http_timeout: 1000,
  http_connect_timeout: 500

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :useless_machine, UselessMachine.Repo,
  database: Path.expand("../useless_machine_test.db", __DIR__),
  pool_size: 5,
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :useless_machine, UselessMachineWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "+YDdTbBKwRxanAktih33KjycfNW5cwx/f7dOPzEU6iyIP9zKu+W+298E7kT0kxsX",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true
