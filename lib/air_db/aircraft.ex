defmodule AirDB.Aircraft do
  use Ecto.Schema

  import Ecto.Changeset

  alias AirDB.Seat
  alias AirDB.Route

  @primary_key false
  schema "aircrafts" do
    field :aircraft_code, :string, primary_key: true
    field :model, :string
    field :range, :integer

    has_many :seats, Seat,
      foreign_key: :aircraft_code,
      references: :aircraft_code,
      on_replace: :mark_as_invalid

    has_many :routes, Route,
      foreign_key: :aircraft_code,
      references: :aircraft_code,
      on_replace: :mark_as_invalid
  end

  @doc false
  def changeset(aircraft, params \\ %{}) do
    aircraft
    |> cast(params, [:aircraft_code, :model, :range])
    |> cast_assoc(:seats, with: &Seat.changeset/2)
    |> validate_required([:aircraft_code, :model, :range])
    |> validate_length(:aircraft_code, is: 3, count: :bytes)
    |> unique_constraint(:aircraft_code, name: :aircrafts_pkey)
    |> check_constraint(:range, name: :aircrafts_range_check, message: "should be greater than 0")
  end
end
