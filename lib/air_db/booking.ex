defmodule AirDB.Booking do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "bookings" do
    field :book_ref, :string, primary_key: true
    field :book_date, :utc_datetime
    field :total_amount, :decimal
  end

  @doc false
  def changeset(booking, params \\ %{}) do
    booking
    |> cast(params, [:book_ref, :book_date, :total_amount])
    |> validate_required([:book_ref, :book_date, :total_amount])
    |> validate_length(:book_ref, is: 6, count: :bytes)
    |> unique_constraint(:book_ref, name: :bookings_pkey)
  end
end
