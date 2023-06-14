defmodule AirDB.TicketFlights do
  use Ecto.Schema
  import Ecto.Changeset
  alias AirDB.Ticket
  alias AirDB.Flight

  @primary_key false
  schema "ticket_flights" do
    field :fare_conditions, :string
    field :amount, :decimal

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
  end

  @doc false
  def changeset(ticket_flight, params \\ %{}) do
    ticket_flight
    |> cast(params, [
      :ticket_no,
      :flight_id,
      :fare_conditions,
      :amount
    ])
    |> cast_assoc(:ticket, with: &Ticket.changeset/2)
    |> cast_assoc(:flight, with: &Flight.changeset/2)
    |> validate_required([:fare_conditions, :amount])
    |> validate_length(:ticket_no, is: 13, count: :bytes)
    |> unique_constraint([:ticket_no, :flight_id], name: :ticket_flights_pkey)
    |> foreign_key_constraint(:ticket_no)
    |> foreign_key_constraint(:flight_id)
    |> check_constraint(:amount, name: :ticket_flights_amount_check)
    |> check_constraint(:fare_conditions, name: :ticket_flights_fare_condition_check)
    |> validate_inclusion(:fare_conditions, ["Economy", "Comfort", "Business"])
  end
end
