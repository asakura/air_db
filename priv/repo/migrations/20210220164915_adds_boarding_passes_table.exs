defmodule AirDB.Repo.Migrations.AddsBoardingPassesTable do
  use Ecto.Migration

  def up do
    create table(:boarding_passes, primary_key: false, comment: "Boarding passes") do
      add :ticket_no,
        references(:ticket_flights, column: :ticket_no, with: [flight_id: :flight_id], type: :char),
        size: 13,
        primary_key: true,
        comment: "Ticket number"

      add :flight_id, :integer, primary_key: true, comment: "Flight ID"
      add :boarding_no, :integer, null: false, comment: "Boarding pass number"
      add :seat_no, :varchar, size: 4, null: false, comment: "Seat number"
    end

    create unique_index(:boarding_passes, [:flight_id, :boarding_no])
    create unique_index(:boarding_passes, [:flight_id, :seat_no])

    execute ~S"""
    ALTER TABLE boarding_passes
      ADD CONSTRAINT "boarding_passes_flight_id_boarding_no_index"
        UNIQUE USING INDEX "boarding_passes_flight_id_boarding_no_index"
    """

    execute ~S"""
    ALTER TABLE boarding_passes
      ADD CONSTRAINT "boarding_passes_flight_id_seat_no_index"
        UNIQUE USING INDEX "boarding_passes_flight_id_seat_no_index"
    """
  end

  def down do
    drop table(:boarding_passes)
  end
end
