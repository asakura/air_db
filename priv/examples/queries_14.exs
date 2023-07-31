import Ecto.Query

alias AirDB.Aircraft
alias AirDB.Airport
alias AirDB.Booking
alias AirDB.Repo
alias AirDB.Route
alias AirDB.Seat

IO.puts("=============================================================")

"""
>>> SELECT count(*) FROM bookings
...  WHERE total_amount > (SELECT avg(total_amount) FROM bookings)
"""
|> IO.puts()

IO.puts("keyword example")

avg_total_query =
  from b in Booking,
    select: avg(b.total_amount)

query =
  from b in Booking,
    where: b.total_amount > subquery(avg_total_query),
    select: count()

Repo.one(query) |> IO.inspect(label: ">>> ")

IO.puts("macro example")

avg_total_query = select(Booking, [b], avg(b.total_amount))

Booking
|> where([b], b.total_amount > subquery(avg_total_query))
|> select([b], count())
|> Repo.one()
|> IO.inspect(label: ">>> ")

IO.puts("Repo shortcut example")

Booking
|> where([b], b.total_amount > subquery(select(Booking, [b], avg(b.total_amount))))
|> Repo.aggregate(:count)
|> IO.inspect(label: ">>> ")

IO.puts("=============================================================")

"""
>>> SELECT flight_no,
...        departure_city,
...        arrival_city
...   FROM routes
...  WHERE departure_city IN (
...      SELECT city
...        FROM airports
...       WHERE timezone ~ 'Krasnoyarsk'
...    )
...    AND arrival_city IN (
...      SELECT city
...        FROM airports
...       WHERE timezone ~ 'Krasnoyarsk'
...    )
"""
|> IO.puts()

IO.puts("keyword example")

cities_query =
  from a in Airport,
    where: fragment("? ~ 'Krasnoyarsk'", a.timezone),
    select: a.city

query =
  from r in Route,
    where: r.departure_city in subquery(cities_query),
    where: r.arrival_city in subquery(cities_query),
    select: map(r, [:flight_no, :departure_city, :arrival_city])

Repo.all(query) |> IO.inspect(label: ">>> ")

IO.puts("macro example")

cities_query =
  Airport
  |> where([a], fragment("? ~ 'Krasnoyarsk'", a.timezone))
  |> select([a], a.city)

Route
|> where([r], r.departure_city in subquery(cities_query))
|> where([r], r.arrival_city in subquery(cities_query))
|> select([r], map(r, [:flight_no, :departure_city, :arrival_city]))
|> Repo.all()
|> IO.inspect(label: ">>> ")

IO.puts("=============================================================")

"""
>>> SELECT airport_name,
...        city,
...        coordinates[1] AS longitude
...   FROM airports
...  WHERE coordinates[1] IN (
...    ( SELECT max(coordinates[1]) FROM airports ),
...    ( SELECT min(coordinates[1]) FROM airports )
...  )
"""
|> IO.puts()

IO.puts("keyword example")

east_airport = from a in Airport, select: max(fragment("?[1]", a.coordinates))
west_airport = from a in Airport, select: min(fragment("?[1]", a.coordinates))

query =
  from a in Airport,
    where: fragment("?[1]", a.coordinates) in [subquery(east_airport), subquery(west_airport)],
    select: map(a, [:airport_name, :city]),
    select_merge: %{longitude: fragment("?[1]", a.coordinates)}

Repo.all(query) |> IO.inspect(label: ">>> ")

IO.puts("macro example")

east_airport = select(Airport, max(fragment("?[1]", a.coordinates)))
west_airport = select(Airport, min(fragment("?[1]", a.coordinates)))

Airport
|> where([a], fragment("?[1]", a.coordinates) in [subquery(east_airport), subquery(west_airport)])
|> select([a], map(a, [:airport_name, :city]))
|> select_merge([a], %{longitude: fragment("?[1]", a.coordinates)})
|> Repo.all()
|> IO.inspect(label: ">>> ")

IO.puts("=============================================================")

"""
>>> SELECT DISTINCT a.city
...   FROM airports AS a
...  WHERE NOT EXISTS (
...     SELECT 1
...       FROM routes AS r
...      WHERE r.departure_city = 'Moscow'
...        AND r.arrival_city = a.city
...    )
...    AND a.city <> 'Moscow'
...  ORDER BY city
"""
|> IO.puts()

IO.puts("keyword example")

route_query =
  from r in Route,
    where: r.departure_city == "Moscow",
    where: r.arrival_city == parent_as(:airport).city,
    select: 1

query =
  from a in Airport,
    as: :airport,
    where: not exists(route_query),
    where: a.city != "Moscow",
    order_by: a.city,
    select: map(a, [:city])

Repo.all(query) |> IO.inspect(label: ">>> ")

IO.puts("macro example")

route_query =
  Route
  |> where([r], r.departure_city == "Moscow")
  |> where([r], r.arrival_city == parent_as(:airport).city)
  |> select([r], 1)

Airport
|> from(as: :airport)
|> where([a], not exists(route_query))
|> where([a], a.city != "Moscow")
|> order_by([a], a.city)
|> select([a], map(a, [:city]))
|> Repo.all()
|> IO.inspect(label: ">>> ")
