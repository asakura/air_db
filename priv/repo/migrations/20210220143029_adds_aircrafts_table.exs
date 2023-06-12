defmodule AirDB.Repo.Migrations.AddsAircraftsTable do
  use Ecto.Migration

  def change do
    create table(:aircrafts, primary_key: false, comment: "Aircrafts") do
      add :aircraft_code, :char, size: 3, primary_key: true, comment: "Aircraft code, IATA"
      add :model, :text, null: false, comment: "Aircraft model"
      add :range, :integer, null: false, comment: "Maximal flying distance, km"
    end

    create constraint(:aircrafts, "aircrafts_range_check", check: "range > 0", comment: "range should be greater than 0")
  end
end
