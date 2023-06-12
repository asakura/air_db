defmodule AirDB.Repo.Migrations.AddsAirportsTable do
  use Ecto.Migration

  def change do
    create table(:airports, primary_key: false, comment: "Airports") do
      add :airport_code, :char, size: 3, primary_key: true, comment: "Airport code"
      add :airport_name, :text, null: false, comment: "Airport name"
      add :city, :text, null: false, comment: "City"
      add :coordinates, :point, null: false, comment: "Airport coordinates (longitude and latitude)"
      add :timezone, :text, null: false, comment: "Airport time zone"
    end
  end
end
