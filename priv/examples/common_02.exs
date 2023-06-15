import Ecto.Query
alias AirDB.Repo
alias AirDB.Aircraft

IO.puts("=============================================================")
IO.puts(">>> SELECT * FROM aircrafts")

Repo.all(Aircraft)
|> IO.inspect()

IO.puts("=============================================================")
IO.puts(">>> SELECT model, aircraft_code, range FROM aircrafts ORDER BY model")

IO.puts("keyword example")

query =
  from a in "aircrafts",
    order_by: a.model,
    select: [a.aircraft_code, a.model, a.range]

query
|> Repo.all()
|> IO.inspect()

IO.puts("expression example")

"aircrafts"
|> order_by([a], asc: a.model)
|> select([a], [a.aircraft_code, a.model, a.range])
|> Repo.all()
|> IO.inspect()

IO.puts("=============================================================")

IO.puts(
  ">>> SELECT model, aircraft_code, range FROM aircrafts WHERE range >= 4000 AND range <= 6000"
)

IO.puts("keyword example")

query =
  from a in "aircrafts",
    where: a.range >= 4000 and a.range <= 6000,
    select: [a.aircraft_code, a.model, a.range]

query
|> Repo.all()
|> IO.inspect()

IO.puts("expression example")

"aircrafts"
|> where([a], a.range >= 4000 and a.range <= 6000)
|> select([a], [a.aircraft_code, a.model, a.range])
|> Repo.all()
|> IO.inspect()

IO.puts("=============================================================")
IO.puts(">>> UPDATE aircrafts SET range = 3500 WHRE aircraft_code = 'SU9'")

IO.puts("keyword example")

query =
  from a in "aircrafts",
    where: a.aircraft_code == "SU9"

query
|> Repo.update_all(set: [range: 3500])
|> IO.inspect()

IO.puts("expression example")

"aircrafts"
|> where([a], a.aircraft_code == "SU9")
|> Repo.update_all(set: [range: 3500])
|> IO.inspect()

IO.puts("=============================================================")
IO.puts(">>> SELECT * FROM aircrafts WHERE aircraft_code = 'SU9'")

IO.puts("keyword example")

query =
  from a in "aircrafts",
    where: a.aircraft_code == "SU9",
    select: [a.aircraft_code, a.model, a.range]

query
|> Repo.all()
|> IO.inspect()

IO.puts("expression example")

"aircrafts"
|> where([a], a.aircraft_code == "SU9")
|> select([a], [a.aircraft_code, a.model, a.range])
|> Repo.all()
|> IO.inspect()

IO.puts("=============================================================")
IO.puts(">>> DELETE FROM aircrafts WHERE aircraft_code = 'CN1'")

IO.puts("keyword example")

query =
  from a in "aircrafts",
    where: a.aircraft_code == "CN1"

query
|> Repo.delete_all()
|> IO.inspect()

IO.puts("expression example")

"aircrafts"
|> where([a], a.aircraft_code == "CN1")
|> Repo.delete_all()
|> IO.inspect()

IO.puts("=============================================================")
IO.puts(">>> DELETE FROM aircrafts WHERE range > 10000 OR range < 3000")

IO.puts("keyword example")

query =
  from a in "aircrafts",
    where: a.range > 10000 or a.range < 3000

query
|> Repo.delete_all()
|> IO.inspect()

IO.puts("expression example")

"aircrafts"
|> where([a], a.range > 10000 or a.range < 3000)
|> Repo.delete_all()
|> IO.inspect()

IO.puts("=============================================================")
IO.puts(">>> DELETE FROM aircrafts")

Repo.delete_all("aircrafts")
