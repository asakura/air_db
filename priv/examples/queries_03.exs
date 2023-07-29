import Ecto.Query

alias AirDB.Aircraft
alias AirDB.Airport
alias AirDB.Repo

IO.puts("=============================================================")
IO.puts(">>> SELECT * FROM aircrafts ORDER BY range DESC")

IO.puts("keyword example")

query =
  from a in Aircraft,
    order_by: [desc: a.range],
    select: map(a, [:aircraft_code, :model, :range])

Repo.all(query) |> IO.inspect(label: ">>> ")

IO.puts("macro example")

Aircraft
|> order_by([a], desc: a.range)
|> select([a], map(a, [:aircraft_code, :model, :range]))
|> Repo.all()
|> IO.inspect(label: ">>> ")

IO.puts("=============================================================")
IO.puts(">>> SELECT timezone FROM airports")

IO.puts("keyword example")

query =
  from a in Airport,
    select: map(a, [:timezone])

Repo.all(query) |> IO.inspect(label: ">>> ")

IO.puts("macro example")

Airport
|> select([a], map(a, [:timezone]))
|> Repo.all()
|> IO.inspect(label: ">>> ")

IO.puts("=============================================================")
IO.puts(">>> SELECT DISTINCT timezone FROM airports ORDER BY 1")

IO.puts("keyword example")

query =
  from a in Airport,
    distinct: true,
    order_by: selected_as(:timezone),
    select: %{timezone: selected_as(a.timezone, :timezone)}

Repo.all(query) |> IO.inspect(label: ">>> ")

IO.puts("macro example")

Airport
|> distinct(true)
|> order_by(selected_as(:timezone))
|> select([a], %{timezone: selected_as(a.timezone, :timezone)})
|> Repo.all()
|> IO.inspect(label: ">>> ")
