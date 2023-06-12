defmodule AirDB.Repo.Migrations.AddsFlightsTable do
  use Ecto.Migration

  def up do
    create table(:flights, primary_key: false, comment: "Flights") do
      add :flight_id, :integer, primary_key: true, comment: "Flight ID"
      add :flight_no, :char, size: 6, null: false, comment: "Flight number"
      add :scheduled_departure, :timestamptz, null: false, comment: "Scheduled departure time"
      add :scheduled_arrival, :timestamptz, null: false, comment: "Scheduled arrival time"

      add :departure_airport_code,
        references(:airports, column: :airport_code, type: :char),
        size: 3,
        null: false,
        comment: "Airport of departure"

      add :arrival_airport_code,
        references(:airports, column: :airport_code, type: :char),
        size: 3,
        null: false,
        comment: "Airport of arrival"

      add :status, :varchar, size: 20, null: false, comment: "Flight status"

      add :aircraft_code,
        references(:aircrafts, column: :aircraft_code, type: :char),
        size: 3,
        null: false,
        comment: "Aircraft code, IATA"

      add :actual_departure, :timestamptz, comment: "Actual departure time"
      add :actual_arrival, :timestamptz, comment: "Actual arrival time"
    end

    create constraint(
      :flights,
      "flights_arrival_time_check",
      check: "scheduled_arrival > scheduled_departure"
    )

    create constraint(
      :flights,
      "flights_actual_arrival_time_check",
      check: "actual_arrival IS NULL OR actual_departure IS NOT NULL AND actual_arrival IS NOT NULL AND actual_arrival > actual_departure"
    )

    create constraint(
      :flights,
      "flights_status_check",
      check: "status = ANY(ARRAY['On Time', 'Delayed', 'Departed', 'Arrived', 'Scheduled', 'Cancelled'])"
    )

    create unique_index(:flights, [:flight_no, :scheduled_departure])

    execute ~S"""
    ALTER TABLE flights
      ADD CONSTRAINT "flights_flight_no_scheduled_departure_index"
        UNIQUE USING INDEX "flights_flight_no_scheduled_departure_index"
    """
  end

  def down do
    drop table(:flights)
  end
end
