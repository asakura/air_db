defmodule AirDB.Repo.Migrations.AddsRoutesView do
  use Ecto.Migration

  def up do
    execute """
    CREATE VIEW routes AS
    WITH f3 AS (
            SELECT f2.flight_no,
                f2.departure_airport_code,
                f2.arrival_airport_code,
                f2.aircraft_code,
                f2.duration,
                array_agg(f2.days_of_week) AS days_of_week
              FROM ( SELECT f1.flight_no,
                        f1.departure_airport_code,
                        f1.arrival_airport_code,
                        f1.aircraft_code,
                        f1.duration,
                        f1.days_of_week
                      FROM ( SELECT flights.flight_no,
                                flights.departure_airport_code,
                                flights.arrival_airport_code,
                                flights.aircraft_code,
                                (flights.scheduled_arrival - flights.scheduled_departure) AS duration,
                                (to_char(flights.scheduled_departure, 'ID'::text))::integer AS days_of_week
                              FROM flights) f1
                      GROUP BY f1.flight_no, f1.departure_airport_code, f1.arrival_airport_code, f1.aircraft_code, f1.duration, f1.days_of_week
                      ORDER BY f1.flight_no, f1.departure_airport_code, f1.arrival_airport_code, f1.aircraft_code, f1.duration, f1.days_of_week) f2
              GROUP BY f2.flight_no, f2.departure_airport_code, f2.arrival_airport_code, f2.aircraft_code, f2.duration
            )
    SELECT f3.flight_no,
        f3.departure_airport_code,
        dep.airport_name AS departure_airport_name,
        dep.city AS departure_city,
        f3.arrival_airport_code,
        arr.airport_name AS arrival_airport_name,
        arr.city AS arrival_city,
        f3.aircraft_code,
        f3.duration,
        f3.days_of_week
      FROM f3,
        airports dep,
        airports arr
      WHERE ((f3.departure_airport_code = dep.airport_code) AND (f3.arrival_airport_code = arr.airport_code))
    """

    execute "COMMENT ON VIEW routes IS 'Routes'"
    execute "COMMENT ON COLUMN routes.flight_no IS 'Flight number'"
    execute "COMMENT ON COLUMN routes.departure_airport_code IS 'Code of airport of departure'"
    execute "COMMENT ON COLUMN routes.departure_airport_name IS 'Name of airport of departure'"
    execute "COMMENT ON COLUMN routes.departure_city IS 'City of departure'"
    execute "COMMENT ON COLUMN routes.arrival_airport_code IS 'Code of airport of arrival'"
    execute "COMMENT ON COLUMN routes.arrival_airport_name IS 'Name of airport of arrival'"
    execute "COMMENT ON COLUMN routes.arrival_city IS 'City of arrival'"
    execute "COMMENT ON COLUMN routes.aircraft_code IS 'Aircraft code, IATA'"
    execute "COMMENT ON COLUMN routes.duration IS 'Scheduled duration of flight'"
    execute "COMMENT ON COLUMN routes.days_of_week IS 'Days of week on which flights are scheduled'"
  end

  def down do
    execute "DROP VIEW routes"
  end
end
