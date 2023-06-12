use Mix.Config

config :air_db, :ecto_repos, [AirDB.Repo]

import_config "#{Mix.env()}.exs"
