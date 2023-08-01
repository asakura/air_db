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
    field :departure_airport_name, :string
    field :departure_city, :string
    field :arrival_airport_name, :string
    field :arrival_city, :string
    field :status, :string
    field :actual_departure, :utc_datetime
    field :actual_departure_local, :naive_datetime
    field :actual_arrival, :utc_datetime
    field :actual_arrival_local, :naive_datetime
    # interval
    field :actual_duration, :binary

    belongs_to :departure_airport, Airport,
      foreign_key: :departure_airport_code,
      references: :airport_code,
      type: :string

    belongs_to :arrival_airport, Airport,
      foreign_key: :arrival_airport_code,
      references: :airport_code,
      type: :string

    belongs_to :aircraft, Aircraft,
      foreign_key: :aircraft_code,
      references: :aircraft_code,
      type: :string
  end
end
