defmodule AirDB.Repo.Migrations.AddsFlightsView do
  use Ecto.Migration

  def up do
    execute """
    CREATE VIEW flights_v AS
     SELECT f.flight_id,
            f.flight_no,
            f.scheduled_departure,
            timezone(dep.timezone, f.scheduled_departure) AS scheduled_departure_local,
            f.scheduled_arrival,
            timezone(arr.timezone, f.scheduled_arrival) AS scheduled_arrival_local,
            (f.scheduled_arrival - f.scheduled_departure) AS scheduled_duration,
            f.departure_airport_code,
            dep.airport_name AS departure_airport_name,
            dep.city AS departure_city,
            f.arrival_airport_code,
            arr.airport_name AS arrival_airport_name,
            arr.city AS arrival_city,
            f.status,
            f.aircraft_code,
            f.actual_departure,
            timezone(dep.timezone, f.actual_departure) AS actual_departure_local,
            f.actual_arrival,
            timezone(arr.timezone, f.actual_arrival) AS actual_arrival_local,
            (f.actual_arrival - f.actual_departure) AS actual_duration
       FROM flights f,
            airports dep,
            airports arr
      WHERE f.departure_airport_code = dep.airport_code
        AND f.arrival_airport_code = arr.airport_code
    """

    execute "COMMENT ON VIEW flights_v IS 'Flights (extended)'"
    execute "COMMENT ON COLUMN flights_v.flight_id IS 'Flight ID'"
    execute "COMMENT ON COLUMN flights_v.flight_no IS 'Flight number'"
    execute "COMMENT ON COLUMN flights_v.scheduled_departure IS 'Scheduled departure time'"
    execute "COMMENT ON COLUMN flights_v.scheduled_departure_local IS 'Scheduled departure time, local time at the point of departure'"
    execute "COMMENT ON COLUMN flights_v.scheduled_arrival IS 'Scheduled arrival time'"
    execute "COMMENT ON COLUMN flights_v.scheduled_arrival_local IS 'Scheduled arrival time, local time at the point of destionation'"
    execute "COMMENT ON COLUMN flights_v.scheduled_duration IS 'Scheduled flight duration'"
    execute "COMMENT ON COLUMN flights_v.departure_airport_code IS 'Departure airport code'"
    execute "COMMENT ON COLUMN flights_v.departure_airport_name IS 'Departure airport name'"
    execute "COMMENT ON COLUMN flights_v.departure_city IS 'City of departure'"
    execute "COMMENT ON COLUMN flights_v.arrival_airport_code IS 'Arrival airport code'"
    execute "COMMENT ON COLUMN flights_v.arrival_airport_name IS 'Arrival airport name'"
    execute "COMMENT ON COLUMN flights_v.arrival_city IS 'City of arrival'"
    execute "COMMENT ON COLUMN flights_v.status IS 'Flight status'"
    execute "COMMENT ON COLUMN flights_v.aircraft_code IS 'Aircraft code, IATA'"
    execute "COMMENT ON COLUMN flights_v.actual_departure IS 'Actual departure time'"
    execute "COMMENT ON COLUMN flights_v.actual_departure_local IS 'Actual departure time, local time at the point of departure'"
    execute "COMMENT ON COLUMN flights_v.actual_arrival IS 'Actual arrival time'"
    execute "COMMENT ON COLUMN flights_v.actual_arrival_local IS 'Actual arrival time, local time at the point of destination'"
    execute "COMMENT ON COLUMN flights_v.actual_duration IS 'Actual flight duration'"
  end

  def down do
    execute "DROP VIEW flights_v"
  end
end
