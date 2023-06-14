defmodule AirDB.Ticket do
  use Ecto.Schema
  import Ecto.Changeset
  alias AirDB.Booking

  @primary_key false
  schema "tickets" do
    field :ticket_no, :string, primary_key: true
    field :passenger_id, :string
    field :passenger_name, :string
    field :contact_data, :map

    belongs_to :booking, Booking,
      foreign_key: :book_ref,
      references: :book_ref,
      type: :string
  end

  @doc false
  def changeset(ticket, params \\ %{}) do
    ticket
    |> cast(params, [
      :ticket_no,
      :book_ref,
      :passenger_id,
      :passenger_name,
      :contact_data
    ])
    |> cast_assoc(:booking, with: &Booking.changeset/2)
    |> validate_required([
      :ticket_no,
      :passenger_id,
      :passenger_name,
      :contact_data
    ])
    |> validate_length(:ticket_no, is: 13, count: :bytes)
    |> validate_length(:book_ref, is: 6, count: :bytes)
    |> validate_length(:passenger_id, min: 11, max: 20, count: :bytes)
    |> unique_constraint(:ticket_no, name: :tickets_pkey)
    |> foreign_key_constraint(:book_ref)
  end
end
