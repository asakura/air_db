import Ecto.Query

alias AirDB.Booking
alias AirDB.Repo
alias AirDB.Route

IO.puts("=============================================================")
IO.puts(">>> SELECT avg(total_amount) FROM bookings")

IO.puts("keyword example")

query =
  from b in Booking,
    select: avg(b.total_amount)

Repo.one(query) |> IO.inspect(label: ">>> ")

IO.puts("macro example")

Booking
|> select([b], avg(b.total_amount))
|> Repo.one()
|> IO.inspect(label: ">>> ")

IO.puts("Repo shortcut example")

Repo.aggregate(Booking, :avg, :total_amount)
|> IO.inspect(label: ">>> ")

IO.puts("=============================================================")
IO.puts(">>> SELECT max(total_amount) FROM bookings")

IO.puts("keyword example")

query =
  from b in Booking,
    select: max(b.total_amount)

Repo.one(query) |> IO.inspect(label: ">>> ")

IO.puts("macro example")

Booking
|> select([b], max(b.total_amount))
|> Repo.one()
|> IO.inspect(label: ">>> ")

IO.inspect("Repo shortcut example")

Repo.aggregate(Booking, :max, :total_amount)
|> IO.inspect(label: ">>> ")

IO.puts("=============================================================")
IO.puts(">>> SELECT min(total_amount) FROM bookings")

IO.puts("keyword example")

query =
  from b in Booking,
    select: min(b.total_amount)

Repo.one(query) |> IO.inspect(label: ">>> ")

IO.puts("macro example")

Booking
|> select([b], min(b.total_amount))
|> Repo.one()
|> IO.inspect(label: ">>> ")

IO.inspect("Repo shortcut example")

Repo.aggregate(Booking, :min, :total_amount)
|> IO.inspect(label: ">>> ")

IO.puts("=============================================================")

"""
>>> SELECT arrival_city, count(*)
...   FROM routes
...  WHERE departure_city = 'Moscow'
...  GROUP BY arrival_city
...  ORDER BY count DESC
"""
|> IO.puts()

IO.puts("keyword example")

query =
  from r in Route,
    where: r.departure_city == "Moscow",
    group_by: r.arrival_city,
    order_by: [desc: selected_as(:count)],
    select: map(r, [:arrival_city]),
    select_merge: %{count: selected_as(count(), :count)}

Repo.all(query) |> IO.inspect(label: ">>> ")

IO.puts("macro example")

Route
|> where([r], r.departure_city == "Moscow")
|> group_by([r], r.arrival_city)
|> order_by([r], desc: selected_as(:count))
|> select([r], map(r, [:arrival_city]))
|> select_merge(%{count: selected_as(count(), :count)})
|> Repo.all()
|> IO.inspect(label: ">>> ")

IO.puts("=============================================================")

"""
>>> SELECT array_length(days_of_week, 1) AS days_per_week, count(*) AS num_routes
...   FROM routes
...  GROUP BY days_per_week
...  ORDER BY 1 desc
"""
|> IO.puts()

IO.puts("keyword example")

query =
  from r in Route,
    group_by: selected_as(:days_per_week),
    order_by: [desc: selected_as(:days_per_week)],
    select: %{
      days_per_week: selected_as(fragment("array_length(?, 1)", r.days_of_week), :days_per_week),
      num_routes: count()
    }

Repo.all(query) |> IO.inspect(label: ">>> ")

IO.puts("macro example")

Route
|> group_by([r], selected_as(:days_per_week))
|> order_by(desc: selected_as(:days_per_week))
|> select([r], %{
  days_per_week: selected_as(fragment("array_length(?, 1)", r.days_of_week), :days_per_week),
  num_routes: count()
})
|> Repo.all()
|> IO.inspect(label: ">>> ")
