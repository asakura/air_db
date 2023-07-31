import Ecto.Query

alias AirDB.Repo
alias AirDB.Route
alias AirDB.Airport

IO.puts("=============================================================")

"""
>>> SELECT departure_city, count(*)
...   FROM routes
...  GROUP BY departure_city
... HAVING count(*) >= 15
...  ORDER BY count DESC
"""
|> IO.puts()

IO.puts("keyword example")

query =
  from r in Route,
    group_by: r.departure_city,
    having: count() >= 15,
    order_by: [desc: selected_as(:count)],
    select: map(r, [:departure_city]),
    select_merge: %{num_routes: selected_as(count(), :count)}

Repo.all(query) |> IO.inspect(label: ">>> ")

IO.puts("macro example")

Route
|> group_by([r], r.departure_city)
|> having(count() >= 15)
|> order_by([r], desc: selected_as(:count))
|> select([r], map(r, [:departure_city]))
|> select_merge([], %{num_routes: selected_as(count(), :count)})
|> Repo.all()
|> IO.inspect(label: ">>> ")

IO.puts("=============================================================")

"""
>>> SELECT city, count(*)
...   FROM airports
...  GROUP BY city
... HAVING count(*) > 1
"""
|> IO.puts()

IO.puts("keyword example")

query =
  from a in Airport,
    group_by: a.city,
    having: count() > 1,
    select: map(a, [:city]),
    select_merge: %{num_airports: count()}

Repo.all(query) |> IO.inspect(label: ">>> ")

IO.puts("macro example")

Airport
|> group_by([a], a.city)
|> having(count() > 1)
|> select([a], map(a, [:city]))
|> select_merge(%{num_airports: count()})
|> Repo.all()
|> IO.inspect(label: ">>> ")
