defmodule AirDB.Route do
  use Ecto.Schema

  @primary_key false
  schema "routes" do
    field :flight_no, :string
    field :departure_airport_code, :string
    field :departure_airport_name, :string
    field :departure_city, :string
    field :arrival_airport_code, :string
    field :arrival_airport_name, :string
    field :arrival_city, :string
    field :aircraft_code, :string
    field :duration, :binary
    field :days_of_week, {:array, :integer}
  end
end
