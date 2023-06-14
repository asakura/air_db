defmodule AirDB.BoardingPass do
  use Ecto.Schema
  import Ecto.Changeset
  alias AirDB.Ticket
  alias AirDB.Flight

  @primary_key false
  schema "boarding_passes" do
    belongs_to :ticket, Ticket,
      primary_key: true,
      foreign_key: :ticket_no,
      references: :ticket_no,
      type: :string

    belongs_to :flight, Flight,
      primary_key: true,
      foreign_key: :flight_id,
      references: :flight_id,
      type: :integer

    field :boarding_no, :integer
    field :seat_no, :string
  end

  @doc false
  def changeset(boarding_pass, params \\ %{}) do
    boarding_pass
    |> cast(params, [:ticket_no, :flight_id, :boarding_no, :seat_no])
    |> validate_required([:ticket_no, :flight_id, :boarding_no, :seat_no])
    |> unique_constraint([:ticket_no, :flight_id], name: :boarding_passes_pkey)
    |> unique_constraint([:flight_id, :boarding_no], message: "boarding no has already been taken")
    |> unique_constraint([:flight_id, :seat_no], message: "seat no has already been taken")
    |> foreign_key_constraint(:ticket_no,
      name: :boarding_passes_ticket_no_fkey,
      message: "ticket_flights does not exist"
    )
    |> validate_length(:ticket_no, is: 13, count: :bytes)
    |> validate_length(:seat_no, min: 2, max: 4, count: :bytes)
  end
end
