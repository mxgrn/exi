import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :exi, Exi.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "exi_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :exi, ExiWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "WpX/TJuAjp0APM2yWULi/tKHnYbL5Cm7gvDmsv3MAC87SY4GyDo8K7/y8ub1hA4P",
  server: false

# In test we don't send emails.
config :exi, Exi.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Disable Oban
config :exi, Oban, queues: false, plugins: false

config :exi, :telegram, bot_id: 5_488_043_084
