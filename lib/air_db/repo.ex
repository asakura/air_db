defmodule AirDB.Repo do
  use Ecto.Repo,
    otp_app: :air_db,
    adapter: Ecto.Adapters.Postgres
end
