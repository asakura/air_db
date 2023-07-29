import Ecto.Query

alias AirDB.Aircraft
alias AirDB.Airport
alias AirDB.Repo

IO.puts("=============================================================")
IO.puts(">>> SELECT * FROM aircrafts WHERE range BETWEEN 3000 AND 6000")

IO.puts("keyword example")

query =
  from a in Aircraft,
    where: fragment("? BETWEEN ? AND ?", a.range, 3000, 6000),
    select: map(a, [:aircraft_code, :model, :range])

Repo.all(query) |> IO.inspect(label: ">>> ")

IO.puts("macro example")

Aircraft
|> where([a], fragment("? BETWEEN ? AND ?", a.range, 3000, 6000))
|> select([a], map(a, [:aircraft_code, :model, :range]))
|> Repo.all()
|> IO.inspect(label: ">>> ")

IO.puts("=============================================================")
IO.puts(">>> SELECT model, range, range / 1.609 AS miles FROM aircrafts")

IO.puts("keyword example")

query =
  from a in Aircraft,
    select: map(a, [:model, :range]),
    select_merge: %{miles: fragment("? / 1.609", a.range)}

Repo.all(query) |> IO.inspect(label: ">>> ")

IO.puts("macro example")

Aircraft
|> select([a], map(a, [:model, :range]))
|> select_merge([a], %{miles: fragment("? / 1.609", a.range)})
|> Repo.all()
|> IO.inspect(label: ">>> ")

IO.puts("=============================================================")
IO.puts(">>> SELECT model, range, round(range / 1.609, 2) AS miles FROM aircrafts")

IO.puts("keyword example")

query =
  from a in Aircraft,
    select: map(a, [:model, :range]),
    select_merge: %{miles: fragment("round(? / 1.609, 2)", a.range)}

Repo.all(query) |> IO.inspect(label: ">>> ")

IO.puts("macro example")

Aircraft
|> select([a], map(a, [:model, :range]))
|> select_merge([a], %{miles: fragment("round(? / 1.609, 2)", a.range)})
|> Repo.all()
|> IO.inspect(label: ">>> ")
