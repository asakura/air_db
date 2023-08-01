IO.puts("=============================================================")

"""
>>> SELECT a.model,
...        ( SELECT count(*)
...            FROM seats AS s
...           WHERE s.aircraft_code = a.aircraft_code
...             AND s.fare_conditions = 'Business'
...        ) AS business,
...        ( SELECT count(*)
...            FROM seats AS s
...           WHERE s.aircraft_code = a.aircraft_code
...             AND s.fare_conditions = 'Comfort'
...        ) AS comfort,
...        ( SELECT count(*)
...            FROM seats AS s
...           WHERE s.aircraft_code = a.aircraft_code
...             AND s.fare_conditions = 'Economy'
...        ) AS economy
...   FROM aircrafts AS a
...  ORDER BY 1
"""
|> IO.puts()

IO.puts("keyword example")

base_query =
  from s in Seat,
    where: s.aircraft_code == parent_as(:aircraft).aircraft_code,
    select: count()

business_query =
  from s in base_query, where: s.fare_conditions == "Business"

comfort_query =
  from s in base_query, where: s.fare_conditions == "Comfort"

economy_query =
  from s in base_query, where: s.fare_conditions == "Economy"

query =
  from a in Aircraft,
    as: :aircraft,
    order_by: a.model,
    select: map(a, [:model]),
    select_merge: %{
      business: subquery(business_query),
      comfort: subquery(comfort_query),
      economy: subquery(economy_query)
    }

Repo.all(query) |> IO.inspect(label: ">>> ")

IO.puts("macro example")

base_query =
  Seat
  |> where([s], s.aircraft_code == parent_as(:aircraft).aircraft_code)
  |> select([s], count())

business_query = where(base_query, [s], s.fare_conditions == "Business")
comfort_query = where(base_query, [s], s.fare_conditions == "Comfort")
economy_query = where(base_query, [s], s.fare_conditions == "Economy")

Aircraft
|> from(as: :aircraft)
|> order_by([a], a.model)
|> select([a], map(a, [:model]))
|> select_merge([a], %{
  business: subquery(business_query),
  comfort: subquery(comfort_query),
  economy: subquery(economy_query)
})
|> Repo.all()
|> IO.inspect(label: ">>> ")

IO.puts("=============================================================")

"""
>>> SELECT s2.model,
...          string_agg(
...            s2.fare_conditions || ' (' || s2.num || ')',
...            ', '
...          )
...   FROM (
...     SELECT a.model,
...            s.fare_conditions,
...            count(*) AS num
...       FROM aircrafts a
...            JOIN seats s
...                ON a.aircraft_code = s.aircraft_code
...      GROUP BY 1, 2
...      ORDER BY 1, 2
...     ) AS s2
...  GROUP BY s2.model
...  ORDER BY s2.model
"""
|> IO.puts()

IO.puts("keyword example")

base_query =
  from a in Aircraft,
    join: s in assoc(a, :seats),
    group_by: [a.model, s.fare_conditions],
    order_by: [a.model, s.fare_conditions],
    select: map(a, [:model]),
    select_merge: map(s, [:fare_conditions]),
    select_merge: %{num: count()}

query =
  from s in subquery(base_query),
    group_by: s.model,
    order_by: s.model,
    select: map(s, [:model]),
    select_merge: %{
      fare_conditions:
        fragment("string_agg(? || ' (' || ? || ')', ', ')", s.fare_conditions, s.num)
    }

Repo.all(query) |> IO.inspect(label: ">>> ")

IO.puts("macro example")

Aircraft
|> join(:inner, [a], s in assoc(a, :seats))
|> group_by([a, s], [a.model, s.fare_conditions])
|> order_by([a, s], [a.model, s.fare_conditions])
|> select([a], map(a, [:model]))
|> select_merge([a, s], map(s, [:fare_conditions]))
|> select_merge(%{num: count()})
|> subquery()
|> group_by([s], s.model)
|> order_by([s], s.model)
|> select([s], map(s, [:model]))
|> select_merge([s], %{
  fare_conditions: fragment("string_agg(? || ' (' || ? || ')', ', ')", s.fare_conditions, s.num)
})
|> Repo.all()
|> IO.inspect(label: ">>> ")
