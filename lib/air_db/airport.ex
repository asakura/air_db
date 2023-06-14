defmodule AirDB.Airport do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "airports" do
    field :airport_code, :string, primary_key: true
    field :airport_name, :string
    field :city, :string
    field :coordinates, AirDB.Ecto.Point
    field :timezone, :string
  end

  @doc false
  def changeset(airport, params \\ %{}) do
    airport
    |> cast(params, [:airport_code, :airport_name, :city, :coordinates, :timezone])
    |> validate_required([:airport_code, :airport_name, :city, :coordinates, :timezone])
    |> validate_length(:airport_code, is: 3, count: :bytes)
    |> unique_constraint(:airport_code, name: :airports_pkey)
  end
end
