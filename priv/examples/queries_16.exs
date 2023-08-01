IO.puts("=============================================================")

"""
>>> SELECT aa.city,
...        aa.airport_code,
...        aa.airport_name
...   FROM (
...     SELECT city, count(*)
...       FROM airports
...      GROUP BY city
...     HAVING count(*) > 1
...   ) AS a
...        JOIN airports AS aa
...            ON a.city = aa.city
...  ORDER BY aa.city, aa.airport_name
"""
|> IO.puts()

IO.puts("keyword example")

base_query =
  from a in Airport,
    group_by: a.city,
    having: count() > 1,
    select: map(a, [:city]),
    select_merge: %{count: count()}

query =
  from a in subquery(base_query),
    join: aa in Airport,
    on: a.city == aa.city,
    order_by: [aa.city, aa.airport_name],
    select: map(aa, [:city, :airport_code, :airport_name])

Repo.all(query) |> IO.inspect(label: ">>> ")

IO.puts("macro example")

Airport
|> group_by([a], a.city)
|> having([a], count() > 1)
|> select([a], map(a, [:city]))
|> select_merge(%{count: count()})
|> subquery()
|> join(:inner, [a], aa in Airport, on: a.city == aa.city)
|> order_by([a, aa], [aa.city, aa.airport_name])
|> select([a, aa], map(aa, [:city, :airport_code, :airport_name]))
|> Repo.all()
|> IO.inspect(label: ">>> ")

IO.puts("=============================================================")

"""
>>> SELECT departure_airport_code,
...        departure_city,
...        count(*)
...   FROM routes
...  GROUP BY departure_airport_code, departure_city
... HAVING departure_airport_code IN (
...   SELECT airport_code
...     FROM airports
...    WHERE coordinates[0] > 150
... )
...  ORDER BY count DESC
"""
|> IO.puts()

IO.puts("keyword example")

airports_query =
  from a in Airport,
    where: fragment("?[0]", a.coordinates) > 150,
    select: a.airport_code

# TODO: doesn't work due to bug in Ecto
query =
  from r in Route,
    group_by: [r.departure_airport_code, r.departure_city],
    having: r.departure_airport_code in subquery(airports_query),
    select: count()

query =
  from r in Route,
    group_by: [r.departure_airport_code, r.departure_city],
    having: r.departure_airport_code in subquery(airports_query),
    order_by: [desc: count()],
    select: map(r, [:departure_airport_code, :departure_city]),
    select_merge: %{count: count()}

Repo.all(query) |> IO.inspect(label: ">>> ")

IO.puts("macro example")

airports_query =
  Airport
  |> where([a], fragment("?[0]", a.coordinates) > 150)
  |> select([a], a.airport_code)

Route
|> group_by([r], [r.departure_airport_code, r.departure_city])
|> having([r], r.departure_airport_code in subquery(airports_query))
|> order_by(desc: count())
|> select([r], map(r, [:departure_airport_code, :departure_city]))
|> select_merge([r], %{count: count()})
|> Repo.all()
|> IO.inspect(label: ">>> ")
