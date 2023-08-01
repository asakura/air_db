import Ecto.Query

alias AirDB.Aircraft
alias AirDB.Airport
alias AirDB.Booking
alias AirDB.FlightExtended
alias AirDB.Repo
alias AirDB.Route
alias AirDB.Seat
alias AirDB.TicketFlights

IO.puts("=============================================================")

"""
>>> SELECT ts.flight_id,
...        ts.flight_no,
...        ts.scheduled_departure_local,
...        ts.departure_city,
...        ts.arrival_city,
...        a.model,
...        ts.fact_passengers,
...        ts.total_seats,
...        round(ts.fact_passengers::numeric / ts.total_seats::numeric, 2) AS fraction
...   FROM ( SELECT f.flight_id,
...                 f.flight_no,
...                 f.scheduled_departure_local,
...                 f.departure_city,
...                 f.arrival_city,
...                 f.aircraft_code,
...                 count(tf.ticket_no) AS fact_passengers,
...                 ( SELECT count(s.seat_no)
...                     FROM seats s
...                    WHERE s.aircraft_code = f.aircraft_code
...                 ) AS total_seats
...            FROM flights_v AS f
...                   JOIN ticket_flights AS tf
...                       ON f.flight_id = tf.flight_id
...           WHERE f.status = 'Arrived'
...           GROUP BY 1, 2, 3, 4, 5, 6
...        ) AS ts
...          JOIN aircrafts AS a ON ts.aircraft_code = a.aircraft_code
...  ORDER BY ts.scheduled_departure_local
...  LIMIT 10
"""
|> IO.puts()

IO.puts("keyword example")

seats_query =
  from s in Seat,
    where: s.aircraft_code == parent_as(:flight).aircraft_code,
    select: count(s.seat_no)

tickets_query =
  from f in FlightExtended,
    as: :flight,
    join: tf in TicketFlights,
    on: f.flight_id == tf.flight_id,
    where: f.status == "Arrived",
    group_by: [
      f.flight_id,
      f.flight_no,
      f.scheduled_departure_local,
      f.departure_city,
      f.arrival_city,
      f.aircraft_code
    ],
    select:
      map(f, [
        :flight_id,
        :flight_no,
        :scheduled_departure_local,
        :departure_city,
        :arrival_city,
        :aircraft_code
      ]),
    select_merge: %{
      fact_passengers: selected_as(count(tf.ticket_no), :fact_passengers),
      total_seats: selected_as(subquery(seats_query), :total_seats)
    }

query =
  from ts in subquery(tickets_query),
    join: a in Aircraft,
    on: ts.aircraft_code == a.aircraft_code,
    order_by: ts.scheduled_departure_local,
    limit: 10,
    select:
      map(ts, [
        :flight_id,
        :flight_no,
        :scheduled_departure_local,
        :departure_city,
        :arrival_city,
        :fact_passengers,
        :total_seats
      ]),
    select_merge: map(a, [:model]),
    select_merge: %{
      fraction:
        type(
          fragment("round(?::numeric / ?::numeric, 2)", ts.fact_passengers, ts.total_seats),
          :float
        )
    }

Repo.all(query) |> IO.inspect(label: ">>> ")

IO.puts("macro example")

seats_query =
  Seat
  |> where([s], s.aircraft_code == parent_as(:flight).aircraft_code)
  |> select([s], count(s.seat_no))

tickets_query =
  FlightExtended
  |> from(as: :flight)
  |> join(:inner, [f], tf in TicketFlights, on: f.flight_id == tf.flight_id)
  |> where([f], f.status == "Arrived")
  |> group_by([f], [
    f.flight_id,
    f.flight_no,
    f.scheduled_departure_local,
    f.departure_city,
    f.arrival_city,
    f.aircraft_code
  ])
  |> select(
    [f],
    map(f, [
      :flight_id,
      :flight_no,
      :scheduled_departure_local,
      :departure_city,
      :arrival_city,
      :aircraft_code
    ])
  )
  |> select_merge(
    [f, tf],
    %{
      fact_passengers: selected_as(count(tf.ticket_no), :fact_passengers),
      total_seats: selected_as(subquery(seats_query), :total_seats)
    }
  )

tickets_query
|> subquery()
|> join(:inner, [ts], a in Aircraft, on: ts.aircraft_code == a.aircraft_code)
|> order_by([ts], ts.scheduled_departure_local)
|> limit(10)
|> select(
  [ts],
  map(ts, [
    :flight_id,
    :flight_no,
    :scheduled_departure_local,
    :departure_city,
    :arrival_city,
    :fact_passengers,
    :total_seats
  ])
)
|> select_merge([ts, a], map(a, [:model]))
|> select_merge([ts], %{
  fraction:
    type(
      fragment("round(?::numeric / ?::numeric, 2)", ts.fact_passengers, ts.total_seats),
      :float
    )
})
|> Repo.all()
|> IO.inspect(label: ">>> ")

IO.puts("=============================================================")

"""
>>> WITH ts AS (
...   SELECT f.flight_id,
...          f.flight_no,
...          f.scheduled_departure_local,
...          f.departure_city,
...          f.arrival_city,
...          f.aircraft_code,
...          count(tf.ticket_no) AS fact_passengers,
...          ( SELECT count(s.seat_no)
...              FROM seats AS s
...             WHERE s.aircraft_code = f.aircraft_code
...          ) AS total_seats
...     FROM flights_v AS f
...            JOIN ticket_flights AS tf
...                ON f.flight_id = tf.flight_id
...    WHERE f.status = 'Arrived'
...    GROUP BY 1, 2, 3, 4, 5, 6
... )
... SELECT ts.flight_id,
...        ts.flight_no,
...        ts.scheduled_departure_local,
...        ts.departure_city,
...        ts.arrival_city,
...        a.model,
...        ts.fact_passengers,
...        ts.total_seats,
...        round(ts.fact_passengers::numeric / ts.total_seats::numeric, 2) AS fraction
...   FROM ts
...          JOIN aircrafts AS a
...              ON a.aircraft_code = ts.aircraft_code
...  ORDER BY ts.scheduled_departure_local
...  LIMIT 10
"""
|> IO.puts()

IO.puts("macro example")

seats_query =
  Seat
  |> where([s], s.aircraft_code == parent_as(:flight).aircraft_code)
  |> select([s], count(s.seat_no))

tickets_query =
  FlightExtended
  |> from(as: :flight)
  |> join(:inner, [f], tf in TicketFlights, on: f.flight_id == tf.flight_id)
  |> where([f], f.status == "Arrived")
  |> group_by([f], [
    f.flight_id,
    f.flight_no,
    f.scheduled_departure_local,
    f.departure_city,
    f.arrival_city,
    f.aircraft_code
  ])
  |> select(
    [f],
    map(f, [
      :flight_id,
      :flight_no,
      :scheduled_departure_local,
      :departure_city,
      :arrival_city,
      :aircraft_code
    ])
  )
  |> select_merge(
    [f, tf],
    %{
      fact_passengers: selected_as(count(tf.ticket_no), :fact_passengers),
      total_seats: selected_as(subquery(seats_query), :total_seats)
    }
  )

"ts"
|> with_cte("ts", as: ^tickets_query)
|> join(:inner, [ts], a in Aircraft, on: ts.aircraft_code == a.aircraft_code)
|> order_by([ts], ts.scheduled_departure_local)
|> limit(10)
|> select(
  [ts],
  map(ts, [
    :flight_id,
    :flight_no,
    :scheduled_departure_local,
    :departure_city,
    :arrival_city,
    :fact_passengers,
    :total_seats
  ])
)
|> select_merge([ts, a], map(a, [:model]))
|> select_merge([ts], %{
  fraction:
    type(
      fragment("round(?::numeric / ?::numeric, 2)", ts.fact_passengers, ts.total_seats),
      :float
    )
})
|> Repo.all()
|> IO.inspect(label: ">>> ")

IO.puts("=============================================================")

"""
>>> WITH RECURSIVE ranges (min_sum, max_sum) AS (
...   VALUES (0, 100000)
...
...   UNION ALL
...
...   SELECT min_sum + 100000, max_sum + 100000
...     FROM ranges
...    WHERE max_sum < (SELECT max(total_amount) FROM bookings)
... )
... SELECT r.min_sum,
...        r.max_sum,
...        count(b.*)
...   FROM bookings AS b
...        RIGHT OUTER JOIN ranges AS r
...            ON b.total_amount >= r.min_sum
...               AND b.total_amount < r.max_sum
...  GROUP BY r.min_sum, r.max_sum
...  ORDER BY r.min_sum
"""
|> IO.puts()

IO.puts("macro example")

# TODO doesn't work because ecto doesn't support selecting from VALUES nor specifing column names for CTE

ranges_recursion_query =
  "ranges"
  |> where([r], r.max_sum < subquery(select(Booking, [b], max(b.total_amount))))
  |> select([r], %{
    min_sum: selected_as(r.min_sum + 100_000, :min_sum),
    max_sum: selected_as(r.max_sum + 100_000, :max_sum)
  })

ranges_query =
  from(fragment("(VALUES (0, 100000))"))
  |> select(%{
    min_sum: selected_as("column1", :min_sum),
    max_sum: selected_as("column2", :max_sum)
  })
  |> union_all(^ranges_recursion_query)

Booking
|> recursive_ctes(true)
|> with_cte("ranges", as: ^subquery(ranges_query))
|> join(:right, [b], r in "ranges",
  on: b.total_amount >= r.min_sum and b.total_amount < r.max_sum
)
|> group_by([b, r], [r.min_sum, r.max_sum])
|> order_by([b, r], r.min_sum)
|> select([b, r], map(r, [:min_sum, :max_sum]))
|> select_merge([b], %{count: count(b)})
|> Repo.all()
|> IO.inspect(label: ">>> ")
