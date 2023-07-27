defmodule AirDB.Repo.Migrations.AddsFlightsView do
  use Ecto.Migration

  import Ecto.Query

  def up do
    query =
      "flights"
      |> from(as: :flight)
      |> join(:inner, [flight: f], dep in "airports",
        on: f.departure_airport_code == dep.airport_code,
        as: :departure_airport
      )
      |> join(:inner, [flight: f], arr in "airports",
        on: f.arrival_airport_code == arr.airport_code,
        as: :arrival_airport
      )
      |> select(
        [flight: f, departure_airport: dep, arrival_airport: arr],
        [
          f.flight_id,
          f.flight_no,
          f.scheduled_departure,
          selected_as(
            fragment("timezone(?, ?)", dep.timezone, f.scheduled_departure),
            :scheduled_departure_local
          ),
          f.scheduled_arrival,
          selected_as(
            fragment("timezone(?, ?)", arr.timezone, f.scheduled_arrival),
            :scheduled_arrival_local
          ),
          selected_as(f.scheduled_arrival - f.scheduled_departure, :scheduled_duration),
          f.departure_airport_code,
          selected_as(dep.airport_name, :departure_airport_name),
          selected_as(dep.city, :departure_city),
          f.arrival_airport_code,
          selected_as(arr.airport_name, :arrival_airport_name),
          selected_as(arr.city, :arrival_city),
          f.status,
          f.aircraft_code,
          f.actual_departure,
          selected_as(
            fragment("timezone(?, ?)", dep.timezone, f.actual_departure),
            :actual_departure_local
          ),
          f.actual_arrival,
          selected_as(
            fragment("timezone(?, ?)", arr.timezone, f.actual_arrival),
            :actual_arrival_local
          ),
          selected_as(f.actual_arrival - f.actual_departure, :actual_duration)
        ]
      )

    {sql_query, []} = Repo.to_sql(:all, query)

    execute("CREATE VIEW flights_v AS #{sql_query}")

    execute("COMMENT ON VIEW flights_v IS 'Flights (extended)'")
    execute("COMMENT ON COLUMN flights_v.flight_id IS 'Flight ID'")
    execute("COMMENT ON COLUMN flights_v.flight_no IS 'Flight number'")
    execute("COMMENT ON COLUMN flights_v.scheduled_departure IS 'Scheduled departure time'")

    execute(
      "COMMENT ON COLUMN flights_v.scheduled_departure_local IS 'Scheduled departure time, local time at the point of departure'"
    )

    execute("COMMENT ON COLUMN flights_v.scheduled_arrival IS 'Scheduled arrival time'")

    execute(
      "COMMENT ON COLUMN flights_v.scheduled_arrival_local IS 'Scheduled arrival time, local time at the point of destionation'"
    )

    execute("COMMENT ON COLUMN flights_v.scheduled_duration IS 'Scheduled flight duration'")
    execute("COMMENT ON COLUMN flights_v.departure_airport_code IS 'Departure airport code'")
    execute("COMMENT ON COLUMN flights_v.departure_airport_name IS 'Departure airport name'")
    execute("COMMENT ON COLUMN flights_v.departure_city IS 'City of departure'")
    execute("COMMENT ON COLUMN flights_v.arrival_airport_code IS 'Arrival airport code'")
    execute("COMMENT ON COLUMN flights_v.arrival_airport_name IS 'Arrival airport name'")
    execute("COMMENT ON COLUMN flights_v.arrival_city IS 'City of arrival'")
    execute("COMMENT ON COLUMN flights_v.status IS 'Flight status'")
    execute("COMMENT ON COLUMN flights_v.aircraft_code IS 'Aircraft code, IATA'")
    execute("COMMENT ON COLUMN flights_v.actual_departure IS 'Actual departure time'")

    execute(
      "COMMENT ON COLUMN flights_v.actual_departure_local IS 'Actual departure time, local time at the point of departure'"
    )

    execute("COMMENT ON COLUMN flights_v.actual_arrival IS 'Actual arrival time'")

    execute(
      "COMMENT ON COLUMN flights_v.actual_arrival_local IS 'Actual arrival time, local time at the point of destination'"
    )

    execute("COMMENT ON COLUMN flights_v.actual_duration IS 'Actual flight duration'")
  end

  def down do
    execute("DROP VIEW flights_v")
  end
end
