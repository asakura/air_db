defmodule AirDB.FlightExtended do
  use Ecto.Schema

  @primary_key false
  schema "flights_v" do
    field :flight_id, :integer
    field :flight_no, :string
    field :scheduled_departure, :utc_datetime
    field :scheduled_departure_local, :naive_datetime
    field :scheduled_arrival, :utc_datetime
    field :scheduled_arrival_local, :naive_datetime
    # interval
    field :scheduled_duration, :binary
    field :departure_airport_code, :string
    field :departure_airport_name, :string
    field :departure_city, :string
    field :arrival_airport_code, :string
    field :arrival_airport_name, :string
    field :arrival_city, :string
    field :status, :string
    field :aircraft_code, :string
    field :actual_departure, :utc_datetime
    field :actual_departure_local, :naive_datetime
    field :actual_arrival, :utc_datetime
    field :actual_arrival_local, :naive_datetime
    # interval
    field :actual_duration, :binary
  end
end
