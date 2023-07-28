import Ecto.Query

alias AirDB.Aircraft
alias AirDB.Repo

# Question no. 2

IO.puts(">>> SELECT * FROM aircrafts ORDER BY range DESC")

query =
  from a in Aircraft,
    order_by: [desc: a.range],
    select: map(a, [:aircraft_code, :model, :range])

Repo.all(query) |> IO.inspect(label: ">>> ")

# Question no. 3

IO.puts(">>> UPDATE aircrafts SET range = range * 2 WHERE aircraft_code = 'SU9'")

query =
  from a in Aircraft,
    where: a.aircraft_code == "SU9",
    update: [set: [range: fragment("range * 2")]]

Repo.update_all(query, []) |> IO.inspect(label: ">>> ")

# Question no. 4

IO.puts(">>> DELETE FROM aircrafts WHERE aircraft_code = 'XXX'")

query =
  from a in Aircraft,
    where: a.aircraft_code == "XXX"

Repo.delete_all(query) |> IO.inspect(label: ">>> ")
