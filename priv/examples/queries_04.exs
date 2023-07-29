import Ecto.Query

alias AirDB.Airport
alias AirDB.Repo

IO.puts("=============================================================")
IO.puts(">>> SELECT airport_name, city, longitude FROM airports ORDER BY longitude DESC LIMIT 3")

IO.puts("keyword example")

query =
  from a in Airport,
    order_by: [desc: selected_as(:longitude)],
    limit: 3,
    select: map(a, [:airport_name, :city]),
    select_merge: %{longitude: selected_as(fragment("?[0]", a.coordinates), :longitude)}

Repo.all(query) |> IO.inspect(label: ">>> ")

IO.puts("macro example")

Airport
|> order_by([a], desc: selected_as(:longitude))
|> limit(3)
|> select([a], map(a, [:airport_name, :city]))
|> select_merge([a], %{longitude: selected_as(fragment("?[0]", a.coordinates), :longitude)})
|> Repo.all()
|> IO.inspect(label: ">>> ")

IO.puts("=============================================================")

IO.puts(
  ">>> SELECT airport_name, city, longitude FROM airports ORDER BY longitude DESC LIMIT 3 OFFSET 3"
)

IO.puts("keyword example")

query =
  from a in Airport,
    order_by: [desc: selected_as(:longitude)],
    limit: 3,
    offset: 3,
    select: map(a, [:airport_name, :city]),
    select_merge: %{longitude: selected_as(fragment("?[0]", a.coordinates), :longitude)}

Repo.all(query) |> IO.inspect(label: ">>> ")

IO.puts("macro example")

Airport
|> order_by([a], desc: selected_as(:longitude))
|> limit(3)
|> offset(3)
|> select([a], map(a, [:airport_name, :city]))
|> select_merge([a], %{longitude: selected_as(fragment("?[0]", a.coordinates), :longitude)})
|> Repo.all()
|> IO.inspect(label: ">>> ")
