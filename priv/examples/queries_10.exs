import Ecto.Query

alias AirDB.Repo
alias AirDB.Route

IO.puts("=============================================================")

"""
>>> SELECT arrival_city FROM routes WHERE departure_city = 'Moscow'
... UNION
... SELECT arrival_city FROM routes WHERE departure_city = 'St. Petersburg'
...  ORDER BY arrival_city
"""
|> IO.puts()

IO.puts("keyword example")

base_query =
  from r in Route,
    where: r.departure_city == "St. Petersburg",
    select: map(r, [:arrival_city])

union_query =
  from r in Route,
    where: r.departure_city == "Moscow",
    union: ^base_query,
    select: map(r, [:arrival_city])

query =
  from u in subquery(union_query),
    select: u.arrival_city,
    order_by: u.arrival_city

Repo.all(query) |> IO.inspect(label: ">>> ")

IO.puts("macro example")

base_query =
  Route
  |> where([r], r.departure_city == "St. Petersburg")
  |> select([r], map(r, [:arrival_city]))

union_query =
  Route
  |> where([r], r.departure_city == "Moscow")
  |> union(^base_query)
  |> select([r], map(r, [:arrival_city]))

union_query
|> subquery()
|> order_by([u], u.arrival_city)
|> select([u], u.arrival_city)
|> Repo.all()
|> IO.inspect(label: ">>> ")

IO.puts("=============================================================")

"""
>>> SELECT arrival_city FROM routes WHERE departure_city = 'Moscow'
... INTERSECT
... SELECT arrival_city FROM routes WHERE departure_city = 'St. Petersburg'
... ORDER BY arrival_city
"""
|> IO.puts()

IO.puts("keyword example")

base_query =
  from r in Route,
    where: r.departure_city == "St. Petersburg",
    select: map(r, [:arrival_city])

intersect_query =
  from r in Route,
    where: r.departure_city == "Moscow",
    intersect: ^base_query,
    select: map(r, [:arrival_city])

query =
  from u in subquery(intersect_query),
    order_by: u.arrival_city,
    select: u.arrival_city

Repo.all(query) |> IO.inspect(label: ">>> ")

IO.puts("macro example")

base_query =
  Route
  |> where([r], r.departure_city == "St. Petersburg")
  |> select([r], map(r, [:arrival_city]))

intersect_query =
  Route
  |> where([r], r.departure_city == "Moscow")
  |> intersect(^base_query)
  |> select([r], map(r, [:arrival_city]))

intersect_query
|> subquery()
|> order_by([u], u.arrival_city)
|> select([u], u.arrival_city)
|> Repo.all()
|> IO.inspect(label: ">>> ")

IO.puts("=============================================================")

"""
>>> SELECT arrival_city FROM routes WHERE departure_city = 'St. Petersburg'
... EXCEPT
... SELECT arrival_city FROM routes WHERE departure_city = 'Moscow'
... ORDER BY arrival_city
"""
|> IO.puts()

IO.puts("keyword example")

base_query =
  from r in Route,
    where: r.departure_city == "Moscow",
    select: map(r, [:arrival_city])

except_query =
  from r in Route,
    where: r.departure_city == "St. Petersburg",
    except: ^base_query,
    select: map(r, [:arrival_city])

query =
  from u in subquery(except_query),
    order_by: u.arrival_city,
    select: u.arrival_city

Repo.all(query) |> IO.inspect(label: ">>> ")

IO.puts("macro example")

base_query =
  Route
  |> where([r], r.departure_city == "Moscow")
  |> select([r], map(r, [:arrival_city]))

except_query =
  Route
  |> where([r], r.departure_city == "St. Petersburg")
  |> except(^base_query)
  |> select([r], map(r, [:arrival_city]))

except_query
|> subquery()
|> order_by([u], u.arrival_city)
|> select([u], u.arrival_city)
|> Repo.all()
|> IO.inspect(label: ">>> ")
