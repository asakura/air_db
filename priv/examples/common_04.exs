import Ecto.Query

alias AirDB.Repo
alias AirDB.Seat

IO.puts("=============================================================")
IO.puts(">>> SELECT count(*) FROM seats WHERE aircraft_code = 'SU9'")

IO.puts("keyword example")

query =
  from s in Seat,
    where: s.aircraft_code == "SU9"

Repo.aggregate(query, :count) |> IO.inspect(label: ">>> ")

IO.puts("macro example")

Seat
|> where([s], s.aircraft_code == "SU9")
|> Repo.aggregate(:count)

IO.puts("=============================================================")
IO.puts(">>> SELECT count(*) FROM seats WHERE aircraft_code = 'CN1'")

query =
  from s in Seat,
    where: s.aircraft_code == "CN1"

Repo.aggregate(query, :count) |> IO.inspect(label: ">>> ")

IO.puts("macro example")

Seat
|> where([s], s.aircraft_code == "CN1")
|> Repo.aggregate(:count)
|> IO.inspect(label: ">>> ")

IO.puts("=============================================================")
IO.puts(">>> SELECT aircraft_code, count(*) FROM seats GROUP BY aircraft_code")

query =
  from s in Seat,
    group_by: s.aircraft_code,
    select: %{aircraft_code: s.aircraft_code, count: count()}

Repo.all(query) |> IO.inspect(label: ">>> ")

IO.puts("macro example")

Seat
|> group_by([s], s.aircraft_code)
|> select([s], %{aircraft_code: s.aircraft_code, count: count()})
|> Repo.all()
|> IO.inspect(label: ">>> ")

IO.puts("=============================================================")
IO.puts(">>> SELECT aircraft_code, count(*) FROM seats GROUP BY aircraft_code ORDER BY count")

query =
  from s in Seat,
    group_by: s.aircraft_code,
    order_by: selected_as(:count),
    select: %{aircraft_code: s.aircraft_code, count: selected_as(count(), :count)}

Repo.all(query) |> IO.inspect(label: ">>> ")

IO.puts("macro example")

Seat
|> group_by([s], s.aircraft_code)
|> order_by(selected_as(:count))
|> select([s], %{aircraft_code: s.aircraft_code, count: selected_as(count(), :count)})
|> Repo.all()
|> IO.inspect(label: ">>> ")

IO.puts("=============================================================")

"""
>>> SELECT aircraft_code, fare_conditions, count(*)
...   FROM seats
...   GROUP BY aircraft_code, fare_conditions
...   ORDER BY aircraft_code, fare_conditions
"""
|> IO.puts()

query =
  from s in Seat,
    group_by: [s.aircraft_code, s.fare_conditions],
    order_by: [s.aircraft_code, s.fare_conditions],
    select: %{aircraft_code: s.aircraft_code, fare_condition: s.fare_conditions, count: count()}

Repo.all(query) |> IO.inspect(label: ">>> ")

IO.puts("macro example")

Seat
|> group_by([s], [s.aircraft_code, s.fare_conditions])
|> order_by([s], [s.aircraft_code, s.fare_conditions])
|> select([s], %{
  aircraft_code: s.aircraft_code,
  fare_condition: s.fare_conditions,
  count: count()
})
|> Repo.all()
|> IO.inspect(label: ">>> ")
