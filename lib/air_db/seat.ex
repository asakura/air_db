defmodule AirDB.Seat do
  use Ecto.Schema
  import Ecto.Changeset
  alias AirDB.Aircraft

  @primary_key false
  schema "seats" do
    belongs_to :aircraft, Aircraft,
      primary_key: true,
      foreign_key: :aircraft_code,
      references: :aircraft_code,
      type: :string

    field :seat_no, :string, primary_key: true
    field :fare_conditions, :string
  end

  @doc false
  def changeset(seat, params \\ %{}) do
    seat
    |> cast(params, [:aircraft_code, :seat_no, :fare_conditions])
    |> cast_assoc(:aircraft, with: &Aircraft.changeset/2)
    |> validate_required([:seat_no, :fare_conditions])
    |> validate_length(:aircraft_code, is: 3, count: :bytes)
    |> validate_length(:seat_no, min: 2, max: 4, count: :bytes)
    |> foreign_key_constraint(:aircraft_code)
    |> unique_constraint([:aircraft_code, :seat_no], name: :seats_pkey)
    |> validate_inclusion(:fare_conditions, ["Economy", "Comfort", "Business"])
    |> check_constraint(:fare_conditions, name: :seats_fare_conditions_check)
  end
end
