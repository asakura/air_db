import Ecto.Query

alias AirDB.BoardingPass
alias AirDB.Flight
alias AirDB.Repo
alias AirDB.Seat
alias AirDB.TicketFlights

IO.puts("=============================================================")

"""
>>> SELECT count(*)
...   FROM ticket_flights t
...  INNER JOIN flights f
...          ON t.flight_id = f.flight_id
...   LEFT OUTER JOIN boarding_passes b
...                ON t.ticket_no = b.ticket_no AND t.flight_id = b.flight_id
...  WHERE f.actual_departure IS NOT NULL AND b.flight_id IS NULL
"""
|> IO.puts()

IO.puts("keyword example")

query =
  from tf in TicketFlights,
    join: f in assoc(tf, :flight),
    left_join: b in BoardingPass,
    on: tf.ticket_no == b.ticket_no and tf.flight_id == b.flight_id,
    # is_nill(b.flight) - позволяет выявить те строки, где не нашлось посадочного билета
    where: not is_nil(f.actual_departure) and is_nil(b.flight_id)

Repo.aggregate(query, :count) |> IO.inspect(label: ">>> ")

IO.puts("macro example")

TicketFlights
|> join(:inner, [t], f in assoc(t, :flight))
|> join(:left, [t], b in BoardingPass,
  on: t.ticket_no == b.ticket_no and t.flight_id == b.flight_id
)
|> where([t, f, b], not is_nil(f.actual_departure) and is_nil(b.flight_id))
|> Repo.aggregate(:count)
|> IO.inspect(label: ">>> ")

IO.puts("=============================================================")
IO.puts("UPDATE boarding_passes SET seat_no = '1A' WHERE flight_id = 1 AND seat_no = '17A'")

IO.puts("keyword example")

query =
  from b in BoardingPass,
    where: b.flight_id == 2 and b.seat_no == "17A",
    update: [set: [seat_no: "1A"]]

Repo.update_all(query, []) |> IO.inspect(label: ">>> ")

IO.puts("macro example")

BoardingPass
|> where([b], b.flight_id == 2 and b.seat_no == "17A")
|> update(set: [seat_no: "1A"])
|> Repo.update_all([])
|> IO.inspect(label: ">>> ")

IO.puts("=============================================================")

"""
>>> SELECT f.flight_no,
...        f.scheduled_departure,
...        f.flight_id,
...        f.departure_airport_code,
...        f.arrival_airport_code,
...        f.aircraft_code,
...        t.passenger_name,
...        tf.fare_conditions AS fc_was,
...        s.fare_conditions AS fc_should_be,
...        b.seat_no
...   FROM boarding_passes b
...   JOIN ticket_flights tf
...     ON b.ticket_no = tf.ticket_no AND b.flight_id = tf.flight_id
...   JOIN tickets t
...     ON tf.ticket_no = t.ticket_no
...   JOIN flights f
...     ON tf.flight_id = f.flight_id
...   JOIN seats s
...     ON b.seat_no = s.seat_no AND f.aircraft_code = s.aircraft_code
...  WHERE tf.fare_conditions <> s.fare_conditions
...  ORDER BY f.flight_no, f.scheduled_departure
"""
|> IO.puts()

IO.puts("keyword example")

query =
  from b in BoardingPass,
    join: tf in TicketFlights,
    on: b.ticket_no == tf.ticket_no and b.flight_id == tf.flight_id,
    join: t in assoc(tf, :ticket),
    join: f in assoc(tf, :flight),
    join: s in Seat,
    on: b.seat_no == s.seat_no and f.aircraft_code == s.aircraft_code,
    where: tf.fare_conditions != s.fare_conditions,
    order_by: [f.flight_no, f.scheduled_departure],
    select:
      map(f, [
        :flight_no,
        :scheduled_departure,
        :flight_id,
        :departure_airport_code,
        :arrival_airport_code,
        :aircraft_code
      ]),
    select_merge: map(t, [:passenger_name]),
    select_merge: map(tf, [:fare_conditions]),
    select_merge: map(s, [:fare_conditions]),
    select_merge: map(b, [:seat_no])

Repo.all(query) |> IO.inspect(label: ">>> ")

IO.puts("macro example")

BoardingPass
|> from(as: :boarding_pass)
|> join(:inner, [boarding_pass: bp], tf in TicketFlights,
  as: :ticket_flights,
  on: bp.ticket_no == tf.ticket_no and bp.flight_id == tf.flight_id
)
|> join(:inner, [ticket_flights: tf], t in assoc(tf, :ticket), as: :ticket)
|> join(:inner, [ticket_flights: tf], f in assoc(tf, :flight), as: :flight)
|> join(:inner, [boarding_pass: bp, flight: f], s in Seat,
  as: :seat,
  on: bp.seat_no == s.seat_no and f.aircraft_code == s.aircraft_code
)
|> where([ticket_flights: tf, seat: s], tf.fare_conditions != s.fare_conditions)
|> order_by([flight: f], [f.flight_no, f.scheduled_departure])
|> select(
  [flight: f],
  map(f, [
    :flight_no,
    :scheduled_departure,
    :flight_id,
    :departure_airport_code,
    :arrival_airport_code,
    :aircraft_code
  ])
)
|> select_merge([ticket: t], map(t, [:passenger_name]))
|> select_merge([ticket_flights: tf], map(tf, [:fare_conditions]))
|> select_merge([seat: s], map(s, [:fare_conditions]))
|> select_merge([boarding_pass: bp], map(bp, [:seat_no]))
|> Repo.all()
|> IO.inspect(label: ">>> ")
