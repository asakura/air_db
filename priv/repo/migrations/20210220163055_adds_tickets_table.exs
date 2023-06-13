defmodule AirDB.Repo.Migrations.AddsTicketsTable do
  use Ecto.Migration

  def change do
    create table(:tickets, primary_key: false, comment: "Tickets") do
      add :ticket_no, :char, size: 13, primary_key: true, comment: "Ticket number"

      add :book_ref,
        references(:bookings, column: :book_ref, type: :char),
        size: 6,
        null: false,
        comment: "Booking number"

      add :passenger_id, :varchar, size: 20, null: false, comment: "Passenger ID"
      add :passenger_name, :text, null: false, comment: "Passenger name"
      add :contact_data, :jsonb, comment: "Passenger contact information"
    end
  end
end
