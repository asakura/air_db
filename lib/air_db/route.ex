defmodule AirDB.Route do
  use Ecto.Schema

  @primary_key false
  schema "routes" do
    field :flight_no, :string
    field :departure_airport_name, :string
    field :departure_city, :string
    field :arrival_airport_name, :string
    field :arrival_city, :string
    field :duration, :binary
    field :days_of_week, {:array, :integer}

    belongs_to :aircraft, AirDB.Aircraft,
      foreign_key: :aircraft_code,
      references: :aircraft_code,
      type: :string

    belongs_to :departure_airport, AirDB.Airport,
      foreign_key: :departure_airport_code,
      references: :airport_code,
      type: :string

    belongs_to :arrival_airport, AirDB.Airport,
      foreign_key: :arrival_airport_code,
      references: :airport_code,
      type: :string
  end
end
