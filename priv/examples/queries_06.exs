import Ecto.Query

alias AirDB.Aircraft
alias AirDB.Flight
alias AirDB.Generators.Airport
alias AirDB.Repo
alias AirDB.Seat

IO.puts("=============================================================")

"""
>>> SELECT a.aircraft_code, a.model, s.seat_no, s.fare_conditions
      FROM seats AS s
      JOIN aircrafts AS a
        ON s.aircraft_code = a.aircraft_code
     WHERE a.model ~ '^Cessna'
     ORDER BY s.seat_no
"""
|> IO.puts()

IO.puts("keyword example")

query =
  from s in Seat,
    join: a in assoc(s, :aircraft),
    where: fragment("? ~ ?", a.model, "^Cessna"),
    order_by: s.seat_no,
    select_merge: map(a, [:aircraft_code, :model]),
    select_merge: map(s, [:seat_no, :fare_conditions])

Repo.all(query) |> IO.inspect(label: ">>> ")

IO.puts("macro example")

Seat
|> join(:inner, [s], a in assoc(a, :aircraft))
|> where([s, a], fragment("? ~ ?", a.model, "^Cessna"))
|> order_by([s], s.seat_no)
|> select_merge([s, a], map(a, [:aircraft_code, :model]))
|> select_merge([s], map(s, [:seat_no, :fare_conditions]))
|> Repo.all()
|> IO.inspect(label: ">>> ")

IO.puts("=============================================================")

"""
>>> SELECT f.flight_id,
           f.flight_no,
           f.scheduled_departure,
           timezone(dep.timezone, f.scheduled_departure) AS scheduled_departure_local,
           f.scheduled_arrival,
           timezone(arr.timezone, f.scheduled_arrival) AS scheduled_arrival_local,
           f.scheduled_arrival - f.scheduled_departure AS scheduled_duration,
           f.departure_airport_code,
           dep.airport_name AS departure_airport_name,
           dep.city AS departure_city,
           f.arrival_airport_code,
           arr.airport_name AS arrival_airport_name,
           arr.city AS arrival_city,
           f.status,
           f.aircraft_code,
           f.actual_departure,
           timezone(dep.timezone, f.actual_departure) AS actual_departure_local,
           f.actual_arrival,
           timezone(arr.timezone, f.actual_arrival) AS actual_arrival_local,
           f.actual_arrival - f.actual_departure AS actual_duration
      FROM flights f,
           airports dep,
           airports arr
     WHERE f.departure_airport_code = dep.airport_code
       AND f.arrival_airport_code = arr.airport_code
"""
|> IO.puts()

IO.puts("keyword example")

timezone = fn airport, field ->
  dynamic(
    [{^airport, a}, flight: f],
    fragment("timezone(?, ?)", a.timezone, field(f, ^field))
  )
end

query =
  from f in Flight,
    as: :flight,
    join: dep in assoc(f, :departure_airport),
    as: :departure_airport,
    join: arr in assoc(f, :arrival_airport),
    as: :arrival_airport,
    limit: 1,
    select_merge:
      map(f, [
        :actual_arrival,
        :actual_departure,
        :aircraft_code,
        :arrival_airport_code,
        :departure_airport_code,
        :flight_id,
        :flight_no,
        :scheduled_arrival,
        :scheduled_departure,
        :status
      ]),
    select_merge: %{
      scheduled_duration: f.scheduled_arrival - f.scheduled_departure,
      actual_duration: f.actual_arrival - f.actual_departure
    },
    select_merge: map(dep, [:airport_name, :city]),
    select_merge: map(arr, [:airport_name, :city]),
    select_merge:
      ^%{
        scheduled_departure_local: timezone.(:departure_airport, :scheduled_departure),
        scheduled_arrival_local: timezone.(:arrival_airport, :scheduled_arrival),
        actual_departure_local: timezone.(:departure_airport, :actual_departure),
        actual_arrival_local: timezone.(:arrival_airport, :actual_arrival)
      }

Repo.all(query) |> IO.inspect(label: ">>> ")

IO.puts("macro example")

from(Flight, as: :flight)
|> join(:inner, [f], dep in assoc(f, :departure_airport), as: :departure_airport)
|> join(:inner, [f], arr in assoc(f, :arrival_airport), as: :arrival_airport)
|> limit(1)
|> select_merge(
  [f],
  map(f, [
    :actual_arrival,
    :actual_departure,
    :aircraft_code,
    :arrival_airport_code,
    :departure_airport_code,
    :flight_id,
    :flight_no,
    :scheduled_arrival,
    :scheduled_departure,
    :status
  ])
)
|> select_merge([f], %{
  scheduled_duration: f.scheduled_arrival - f.scheduled_departure,
  actual_duration: f.actual_arrival - f.actual_departure
})
|> select_merge([departure_airport: dep], map(dep, [:airport_name, :city]))
|> select_merge([arrival_airport: arr], map(arr, [:airport_name, :city]))
|> select_merge(
  ^%{
    scheduled_departure_local: timezone.(:departure_airport, :scheduled_departure),
    scheduled_arrival_local: timezone.(:arrival_airport, :scheduled_arrival),
    actual_departure_local: timezone.(:departure_airport, :actual_departure),
    actual_arrival_local: timezone.(:arrival_airport, :actual_arrival)
  }
)
|> Repo.all()
|> IO.inspect(label: ">>> ")

IO.puts("=============================================================")
IO.puts(">>> SELECT count(*) FROM airports a1, airports a2 WHERE a1.city <> a2.city")

IO.puts("keyword example")

query =
  from a1 in Airport,
    join: a2 in Airport,
    where: a1.city != a2.city

Repo.aggregate(query, :count) |> IO.inspect(label: ">>> ")

IO.puts("macro example")

Airport
|> join(:inner, [a1], a2 in Airport)
|> where([a1, a2], a1.city != a2.city)
|> Repo.aggregate(:count)
|> IO.inspect(label: ">>> ")

IO.puts("=============================================================")
IO.puts(">>> SELECT count(*) FROM airports a1 JOIN airports a2 ON a1.city <> a2.city")

IO.puts("keyword example")

query =
  from a1 in Airport,
    join: a2 in Airport,
    on: a1.city != a2.city

Repo.aggregate(query, :count) |> IO.inspect(label: ">>> ")

IO.puts("macro example")

Airport
|> join(:inner, [a1], a2 in Airport, on: a1.city != a2.city)
|> Repo.aggregate(:count)
|> IO.inspect(label: ">>> ")

IO.puts("=============================================================")
IO.puts(">>> SELECT count(*) FROM airports a1 CROSS JOIN airports a2 WHERE a1.city <> a2.city")

IO.puts("keyword example")

query =
  from a1 in Airport,
    cross_join: a2 in Airport,
    where: a1.city != a2.city

Repo.aggregate(query, :count) |> IO.inspect(label: ">>> ")

IO.puts("macro example")

Airport
|> join(:cross, [a1], a2 in Airport)
|> where([a1, a2], a1.city != a2.city)
|> Repo.aggregate(:count)
|> IO.inspect(label: ">>> ")
