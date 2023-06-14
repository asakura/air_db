defmodule AirDB.Flight do
  use Ecto.Schema
  import Ecto.Changeset
  alias AirDB.Airport
  alias AirDB.Aircraft

  @primary_key false
  schema "flights" do
    field :flight_id, :integer, primary_key: true
    field :flight_no, :string

    field :scheduled_departure, :utc_datetime
    field :scheduled_arrival, :utc_datetime

    field :status, :string

    field :actual_departure, :utc_datetime
    field :actual_arrival, :utc_datetime

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

  @doc false
  def changeset(flight, params \\ %{}) do
    flight
    |> cast(params, [
      :flight_id,
      :flight_no,
      :scheduled_departure,
      :scheduled_arrival,
      :departure_airport_code,
      :arrival_airport_code,
      :status,
      :aircraft_code,
      :actual_departure,
      :actual_arrival
    ])
    |> cast_assoc(:departure_airport, with: &Airport.changeset/2)
    |> cast_assoc(:arrival_airport, with: &Airport.changeset/2)
    |> cast_assoc(:aircraft, with: &Aircraft.changeset/2)
    |> validate_required([
      :flight_id,
      :flight_no,
      :scheduled_departure,
      :scheduled_arrival,
      :status
    ])
    |> validate_length(:flight_no, is: 6, count: :bytes)
    |> validate_length(:departure_airport_code, is: 3, count: :bytes)
    |> validate_length(:arrival_airport_code, is: 3, count: :bytes)
    |> validate_length(:aircraft_code, is: 3, count: :bytes)
    |> validate_inclusion(:status, [
      "On Time",
      "Delayed",
      "Departed",
      "Arrived",
      "Scheduled",
      "Cancelled"
    ])
    |> check_constraint(:status, name: :flights_status_check)
    |> check_constraint(:scheduled_arrival, name: :flights_arrival_time_check)
    |> check_constraint(:actual_arrival, name: :flights_actual_arrival_time_check)
    |> unique_constraint(:flight_id, name: :flights_pkey)
    |> unique_constraint([:flight_no, :scheduled_departure])
    |> foreign_key_constraint(:departure_airport_code)
    |> foreign_key_constraint(:arrival_airport_code)
    |> foreign_key_constraint(:aircraft_code)
  end
end
