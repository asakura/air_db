defmodule AirDB.Ecto.Point do
  @behaviour Ecto.Type

  def type, do: Postgrex.Point

  def cast(%Postgrex.Point{} = value), do: {:ok, value}

  def cast(value) when is_binary(value) do
    with [_, x, y] <- Regex.run(~r/\((.*?),(.*?)\)/, value),
         {x, ""} <- Float.parse(x),
         {y, ""} <- Float.parse(y) do
      {:ok, %Postgrex.Point{x: x, y: y}}
    else
      _ -> :error
    end
  end

  def cast(_), do: :error

  # loading data from the database
  def load(data) do
    {:ok, data}
  end

  # dumping data to the database
  def dump(%Postgrex.Point{} = value), do: {:ok, value}
  def dump(_), do: :error

  def equal?(%Postgrex.Point{} = a, %Postgrex.Point{} = a), do: true
  def equal?(_, _), do: false

  def embed_as(_), do: :self
end
