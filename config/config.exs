# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :useless_machine,
  ecto_repos: [UselessMachine.Repo],
  generators: [timestamp_type: :utc_datetime],
  http_timeout: 5000,          # 5 second timeout for the entire request
  http_connect_timeout: 3000   # 3 second timeout for establishing connection

# Configures the endpoint
config :useless_machine, UselessMachineWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: UselessMachineWeb.ErrorHTML, json: UselessMachineWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: WhereMachines.PubSub,
  live_view: [signing_salt: "4t7uCxHj"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  useless_machine: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.3",
  useless_machine: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
