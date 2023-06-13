defmodule AirDB.Repo.Migrations.AddsTicketFlightsTable do
  use Ecto.Migration

  def change do
    create table(:ticket_flights, primary_key: false, comment: "Flight segment") do
      add :ticket_no,
        references(:tickets, column: :ticket_no, type: :char),
        size: 13,
        primary_key: true,
        comment: "Ticket number"

      add :flight_id,
        references(:flights, column: :flight_id, type: :integer),
        primary_key: true,
        comment: "Flight ID"

      add :fare_conditions, :varchar, size: 10, null: false, comment: "Travel class"
      add :amount, :numeric, precision: 10, scale: 2, null: false, comment: "Travel cost"
    end

    create constraint(:ticket_flights, "ticket_flights_amount_check", check: "amount > 0")
    create constraint(
      :ticket_flights,
      "ticket_flights_fare_condition_check",
      check: "fare_conditions = ANY(ARRAY['Economy', 'Comfort', 'Business'])"
    )
  end
end
