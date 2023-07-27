import Ecto.Query

alias AirDB.Aircraft
alias AirDB.Repo

IO.puts("=============================================================")
IO.puts(">>> SELECT * FROM aircrafts")

select(Aircraft, [a], map(a, ^Aircraft.__schema__(:fields)))
|> Repo.all()
|> IO.inspect(label: ">>> ")

IO.puts("=============================================================")
IO.puts(">>> SELECT model, aircraft_code, range FROM aircrafts ORDER BY model")

IO.puts("keyword example")

query =
  from a in Aircraft,
    order_by: a.model,
    select: map(a, [:aircraft_code, :model, :range])

Repo.all(query) |> IO.inspect(label: ">>> ")

IO.puts("macro example")

Aircraft
|> order_by([a], asc: a.model)
|> select([a], map(a, [:aircraft_code, :model, :range]))
|> Repo.all()
|> IO.inspect(label: ">>> ")

IO.puts("=============================================================")

IO.puts(
  ">>> SELECT model, aircraft_code, range FROM aircrafts WHERE range >= 4000 AND range <= 6000"
)

IO.puts("keyword example")

query =
  from a in Aircraft,
    where: a.range >= 4000 and a.range <= 6000,
    select: map(a, [:aircraft_code, :model, :range])

Repo.all(query) |> IO.inspect(label: ">>> ")

IO.puts("macro example")

Aircraft
|> where([a], a.range >= 4000 and a.range <= 6000)
|> select([a], map(a, [:aircraft_code, :model, :range]))
|> Repo.all()
|> IO.inspect(label: ">>> ")

IO.puts("=============================================================")
IO.puts(">>> UPDATE aircrafts SET range = 3500 WHRE aircraft_code = 'SU9'")

IO.puts("keyword example")

query =
  from a in Aircraft,
    where: a.aircraft_code == "SU9"

Repo.update_all(query, set: [range: 3500]) |> IO.inspect(label: ">>> ")

IO.puts("macro example")

Aircraft
|> where([a], a.aircraft_code == "SU9")
|> Repo.update_all(set: [range: 3500])
|> IO.inspect(label: ">>> ")

IO.puts("=============================================================")
IO.puts(">>> SELECT * FROM aircrafts WHERE aircraft_code = 'SU9'")

IO.puts("keyword example")

query =
  from a in Aircraft,
    where: a.aircraft_code == "SU9",
    select: map(a, [:aircraft_code, :model, :range])

Repo.one(query) |> IO.inspect(label: ">>> ")

IO.puts("macro example")

Aircraft
|> where([a], a.aircraft_code == "SU9")
|> select([a], map(a, [:aircraft_code, :model, :range]))
|> Repo.one()
|> IO.inspect(label: ">>> ")

IO.puts("=============================================================")
IO.puts(">>> DELETE FROM aircrafts WHERE aircraft_code = 'CN1'")

IO.puts("keyword example")

query =
  from a in Aircraft,
    where: a.aircraft_code == "CN1"

Repo.delete_all(query) |> IO.inspect(label: ">>> ")

IO.puts("macro example")

Aircraft
|> where([a], a.aircraft_code == "CN1")
|> Repo.delete_all()
|> IO.inspect(label: ">>> ")

IO.puts("=============================================================")
IO.puts(">>> DELETE FROM aircrafts WHERE range > 10000 OR range < 3000")

IO.puts("keyword example")

query =
  from a in Aircraft,
    where: a.range > 10000 or a.range < 3000

Repo.delete_all(query) |> IO.inspect(label: ">>> ")

IO.puts("macro example")

Aircraft
|> where([a], a.range > 10000 or a.range < 3000)
|> Repo.delete_all()
|> IO.inspect(label: ">>> ")

IO.puts("=============================================================")
IO.puts(">>> DELETE FROM aircrafts")

Repo.delete_all(Aircraft) |> IO.inspect(label: ">>> ")
