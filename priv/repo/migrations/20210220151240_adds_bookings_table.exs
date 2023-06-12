defmodule AirDB.Repo.Migrations.AddsBookingsTable do
  use Ecto.Migration

  def change do
    create table(:bookings, primary_key: false, comment: "Bookings") do
      add :book_ref, :char, size: 6, primary_key: true, comment: "Booking number"
      add :book_date, :timestamptz, null: false, comment: "Booking date"
      add :total_amount, :numeric, null: false, precision: 10, scale: 2, comment: "Total booking cost"
    end
  end
end
