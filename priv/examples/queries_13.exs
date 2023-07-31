import Ecto.Query

alias AirDB.Repo
alias AirDB.TicketFlights
alias AirDB.Airport

IO.puts("=============================================================")

"""
>>> SELECT b.book_ref,
...        b.book_date,
...        extract('month' from b.book_date) AS month,
...        extract('day' from b.book_date) AS day,
...        count(*) OVER (
...          PARTITION BY date_trunc('month', b.book_date)
...          ORDER BY b.book_date
...        ) AS count
...   FROM ticket_flights tf
...   JOIN tickets t ON tf.ticket_no = t.ticket_no
...   JOIN bookings b ON t.book_ref = b.book_ref
...  WHERE tf.flight_id = 2
...  ORDER BY b.book_date
"""
|> IO.puts()

IO.puts("keyword example")

extract = fn
  :month, from, field ->
    dynamic([{^from, q}], fragment("extract('month' FROM ?)", field(q, ^field)))

  :day, from, field ->
    dynamic([{^from, q}], fragment("extract('day' FROM ?)", field(q, ^field)))
end

query =
  from tf in TicketFlights,
    join: t in assoc(tf, :ticket),
    join: b in assoc(t, :booking),
    as: :booking,
    where: tf.flight_id == 2,
    windows: [
      month: [
        partition_by: fragment("date_trunc('month', ?)", b.book_date),
        order_by: b.book_date
      ]
    ],
    limit: 13,
    select: map(b, [:book_ref, :book_date]),
    select_merge:
      ^%{
        month: extract.(:month, :booking, :book_date),
        day: extract.(:day, :booking, :book_date)
      },
    select_merge: %{
      count: over(count(), :month)
    }

Repo.all(query) |> IO.inspect(label: ">>> ")

IO.puts("macro example")

TicketFlights
|> from(as: :ticket_flights)
|> join(:inner, [ticket_flights: tf], t in assoc(tf, :ticket), as: :ticket)
|> join(:inner, [ticket: t], b in assoc(t, :booking), as: :booking)
|> where([ticket_flights: tf], tf.flight_id == 2)
|> windows([ticket_flights: tf, booking: b],
  month: [
    partition_by: fragment("date_trunc('month', ?)", b.book_date),
    order_by: b.book_date
  ]
)
|> limit(13)
|> select([booking: b], map(b, [:book_ref, :book_date]))
|> select_merge(
  [booking: b],
  ^%{
    month: extract.(:month, :booking, :book_date),
    day: extract.(:day, :booking, :book_date)
  }
)
|> select_merge(%{
  count: over(count(), :month)
})
|> Repo.all()
|> IO.inspect(label: ">>> ")

IO.puts("=============================================================")

"""
>>> SELECT airport_name,
...        city,
...        round(coordinates[1]::numeric, 2) AS ltd,
...        timezone,
...        rank() OVER (
...          PARTITION BY timezone
...          ORDER BY coordinates[1] DESC
...        )
...   FROM airports
...  WHERE timezone IN ('Asia/Irkutsk', 'Asia/Krasnoyarsk')
...  ORDER BY timezone, rank()
"""
|> IO.puts()

IO.puts("keyword example")

query =
  from a in Airport,
    where: a.timezone in ["Asia/Irkutsk", "Asia/Krasnoyarsk"],
    order_by: [a.timezone, selected_as(:rank)],
    windows: [
      timezone: [
        partition_by: a.timezone,
        order_by: [desc: fragment("?[1]", a.coordinates)]
      ]
    ],
    select: map(a, [:airport_name, :timezone]),
    select_merge: %{
      ltd: fragment("round(?[1]::numeric, 2)", a.coordinates),
      rank: selected_as(over(rank(), :timezone), :rank)
    }

Repo.all(query) |> IO.inspect(label: ">>> ")

IO.puts("macro example")

Airport
|> where([a], a.timezone in ["Asia/Irkutsk", "Asia/Krasnoyarsk"])
|> order_by([a], [a.timezone, selected_as(:rank)])
|> windows([a],
  timezone: [
    partition_by: a.timezone,
    order_by: [desc: fragment("?[1]", a.coordinates)]
  ]
)
|> select([a], map(a, [:airport_name, :timezone]))
|> select_merge([a], %{
  ltd: fragment("round(?[1]::numeric, 2)", a.coordinates),
  rank: selected_as(over(rank(), :timezone), :rank)
})
|> Repo.all()
|> IO.inspect(label: ">>> ")

IO.puts("=============================================================")

"""
>>> SELECT airport_name,
...        city,
...        timezone,
...        coordinates[1] AS ltd,
...        first_value(coordinates[1])                  OVER tz AS first_in_timezone,
...        coordinates[1] - first_value(coordinates[1]) OVER tz AS delta,
...        rank()                                       OVER tz
...   FROM airports
...  WHERE timezone IN ('Asia/Irkutsk', 'Asia/Krasnoyarsk')
... WINDOW tz AS (PARTITION BY timezone ORDER BY coordinates[1] DESC)
...  ORDER BY timezone, rank
"""
|> IO.puts()

IO.puts("keyword example")

query =
  from a in Airport,
    where: a.timezone in ["Asia/Irkutsk", "Asia/Krasnoyarsk"],
    order_by: [a.timezone, selected_as(:rank)],
    windows: [
      tz: [
        partition_by: a.timezone,
        order_by: [desc: fragment("?[1]", a.coordinates)]
      ]
    ],
    select: map(a, [:airport_name, :city, :timezone]),
    select_merge: %{
      ltd: fragment("?[1]", a.coordinates),
      first_in_timezone: over(first_value(fragment("?[1]", a.coordinates)), :tz),
      delta:
        over(
          fragment("?[1] - ?", a.coordinates, first_value(fragment("?[1]", a.coordinates))),
          :tz
        ),
      rank: selected_as(over(rank(), :tz), :rank)
    }

Repo.all(query) |> IO.inspect(label: ">>> ")

IO.puts("macro example")

Airport
|> where([a], a.timezone in ["Asia/Irkutsk", "Asia/Krasnoyarsk"])
|> order_by([a], [a.timezone, selected_as(:rank)])
|> windows([a],
  tz: [
    partition_by: a.timezone,
    order_by: [desc: fragment("?[1]", a.coordinates)]
  ]
)
|> select([a], map(a, [:airport_name, :city, :timezone]))
|> select_merge([a], %{
  ltd: fragment("?[1]", a.coordinates),
  first_in_timezone: over(first_value(fragment("?[1]", a.coordinates)), :tz),
  delta:
    over(fragment("?[1] - ?", a.coordinates, first_value(fragment("?[1]", a.coordinates))), :tz),
  rank: selected_as(over(rank(), :tz), :rank)
})
|> Repo.all()
|> IO.inspect(label: ">>> ")
