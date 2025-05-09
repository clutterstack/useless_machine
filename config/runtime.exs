import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

# ## Using releases
#
# If you use `mix release`, you need to explicitly enable the server
# by passing the PHX_SERVER=true when you start it:
#
#     PHX_SERVER=true bin/useless_machine start
#
# Alternatively, you can use `mix phx.gen.release` to generate a `bin/server`
# script that automatically sets the env var above.
if System.get_env("PHX_SERVER") do
  config :useless_machine, UselessMachineWeb.Endpoint, server: true
end

config :useless_machine,
  machine_end_state: System.get_env("USELESS_MACHINE_END_STATE", "stopped"),
  final_view: System.get_env("USELESS_MACHINE_FINAL_VIEW", "bye"),
  life_cycle_end: System.get_env("USELESS_MACHINE_LIFE_CYCLE_END", "stopped"),
  life_cycle_timeout: System.get_env("USELESS_MACHINE_SHUTDOWN_TIMEOUT", "60000")

if config_env() == :prod do
  # database_path =
  #   System.get_env("DATABASE_PATH") ||
  #     raise """
  #     environment variable DATABASE_PATH is missing.
  #     For example: /etc/useless_machine/useless_machine.db
  #     """

  # config :useless_machine, UselessMachine.Repo,
  #   database: database_path,
  #   pool_size: String.to_integer(System.get_env("POOL_SIZE") || "5")

  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  # where_machines_url = System.get_env("WHERE_MACHINES_URL") || "http://where.internal:4001/api/machine_status"
  requestor_ip = System.get_env("REQUESTOR_IP")
  requestor_api_port = System.get_env("REQUESTOR_API_PORT") || "4001"

  config :useless_machine,
    machine_id: System.get_env("FLY_MACHINE_ID"),
    where_machines_url: "http://[#{requestor_ip}]:#{requestor_api_port}/api/machine_status"

  host = System.get_env("PHX_HOST") || "example.com"
  port = String.to_integer(System.get_env("PORT") || "4040")
  self_by_ipv6 = "http://[#{System.get_env("FLY_PRIVATE_IP")}]:#{System.get_env("PORT")}"

  config :useless_machine, UselessMachineWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    # Add this line to allow localhost:4040 as a valid origin
    check_origin: [
      "https://useless-machine-quiet-cherry-9553.fly.dev",
      "https://useless-machine.fly.dev",
      self_by_ipv6
      ],
    http: [
      # Enable IPv6 and bind on all interfaces.
      # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
      # See the documentation on https://hexdocs.pm/bandit/Bandit.html#t:options/0
      # for details about using IPv6 vs IPv4 and loopback vs public addresses.
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base

  # ## SSL Support
  #
  # To get SSL working, you will need to add the `https` key
  # to your endpoint configuration:
  #
  #     config :useless_machine, UselessMachineWeb.Endpoint,
  #       https: [
  #         ...,
  #         port: 443,
  #         cipher_suite: :strong,
  #         keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
  #         certfile: System.get_env("SOME_APP_SSL_CERT_PATH")
  #       ]
  #
  # The `cipher_suite` is set to `:strong` to support only the
  # latest and more secure SSL ciphers. This means old browsers
  # and clients may not be supported. You can set it to
  # `:compatible` for wider support.
  #
  # `:keyfile` and `:certfile` expect an absolute path to the key
  # and cert in disk or a relative path inside priv, for example
  # "priv/ssl/server.key". For all supported SSL configuration
  # options, see https://hexdocs.pm/plug/Plug.SSL.html#configure/1
  #
  # We also recommend setting `force_ssl` in your config/prod.exs,
  # ensuring no data is ever sent via http, always redirecting to https:
  #
  #     config :useless_machine, UselessMachineWeb.Endpoint,
  #       force_ssl: [hsts: true]
  #
  # Check `Plug.SSL` for all available options in `force_ssl`.
end
