import Config

config :air_db, AirDB.Repo,
  database: "air_db_dev",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  pool_size: 10
