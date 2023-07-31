import Ecto.Query

alias AirDB.Aircraft
alias AirDB.Airport
alias AirDB.Repo

IO.puts("=============================================================")
IO.puts(">>> SELECT * FROM aircrafts WHERE model LIKE 'Airbus%'")

IO.puts("keyword example")

query =
  from a in Aircraft,
    where: like(a.model, "Airbus%"),
    select: map(a, [:aircraft_code, :model, :range])

Repo.all(query) |> IO.inspect(label: ">>> ")

IO.puts("macro example")

Aircraft
|> where([a], like(a.model, "Airbus%"))
|> select([a], map(a, [:aircraft_code, :model, :range]))
|> Repo.all()
|> IO.inspect(label: ">>> ")

IO.puts("=============================================================")

"""
>>> SELECT * FROM aircrafts
...  WHERE model NOT LIKE 'Airbus%'
...    AND model NOT LIKE 'Boeing%'
"""
|> IO.puts()

IO.puts("keyword example")

query =
  from a in Aircraft,
    where: not like(a.model, "Airbus%") and not like(a.model, "Boeing%"),
    select: map(a, [:aircraft_code, :model, :range])

Repo.all(query) |> IO.inspect(label: ">>> ")

IO.puts("macro example")

Aircraft
|> where([a], not like(a.model, "Airbus%") and not like(a.model, "Boeing%"))
|> select([a], map(a, [:aircraft_code, :model, :range]))
|> Repo.all()
|> IO.inspect(label: ">>> ")

IO.puts("=============================================================")
IO.puts(">>> SELECT * FROM airports WHERE airport_name LIKE '____________'")

IO.puts("keyword example")

query =
  from a in Airport,
    where: like(a.airport_name, "____________"),
    select: map(a, [:airport_code, :airport_name, :city])

Repo.all(query) |> IO.inspect(label: ">>> ")

IO.puts("macro example")

Airport
|> where([a], like(a.airport_name, "____________"))
|> select([a], map(a, [:airport_code, :airport_name, :city]))
|> Repo.all()
|> IO.inspect(label: ">>> ")

IO.puts("=============================================================")
IO.puts(">>> SELECT * FROM aircrafts WHERE model ~ '^(A|Boe)'")

IO.puts("keyword example")

query =
  from a in Aircraft,
    where: fragment("? ~ ?", a.model, "^(A|Boe)"),
    select: map(a, [:aircraft_code, :model, :range])

Repo.all(query) |> IO.inspect(label: ">>> ")

IO.puts("macro example")

Aircraft
|> where([a], fragment("? ~ ?", a.model, "^(A|Boe)"))
|> select([a], map(a, [:aircraft_code, :model, :range]))
|> Repo.all()
|> IO.inspect()

IO.puts("=============================================================")
IO.puts(">>> SELECT * FROM aircrafts WHERE model !~ '300$'")

IO.puts("keyword example")

query =
  from a in Aircraft,
    where: fragment("? !~ ?", a.model, "300$"),
    select: map(a, [:aircraft_code, :model, :range])

Repo.all(query) |> IO.inspect()

IO.puts("macro example")

Aircraft
|> where([a], fragment("? !~ ?", a.model, "300$"))
|> select([a], map(a, [:aircraft_code, :model, :range]))
|> Repo.all()
|> IO.inspect()
