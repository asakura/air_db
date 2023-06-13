defmodule AirDB.Repo.Migrations.AddsSeatsTable do
  use Ecto.Migration

  def change do
    create table(:seats, primary_key: false, comment: "Seats") do
      add :aircraft_code,
        references(:aircrafts, column: :aircraft_code, type: :char, on_delete: :delete_all),
        size: 3,
        primary_key: true,
        comment: "Aircraft code, IATA"

      add :seat_no, :varchar, size: 4, primary_key: true, comment: "Seat number"
      add :fare_conditions, :varchar, size: 10, null: false, comment: "Travel class"
    end

    create constraint(
      :seats,
      "seats_fare_conditions_check",
      check: "fare_conditions = ANY(ARRAY['Economy', 'Comfort', 'Business'])"
    )
  end
end
