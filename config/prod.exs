use Mix.Config

config :rumbl, RumblWeb.Endpoint,
  http: [port: 4000],
  debug_errors: false,
  code_reloader: false,
  check_origin: false

config :logger, level: :info

config :rumbl, Rumbl.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "telemetry_rumbl",
  hostname: "localhost",
  pool_size: 10

