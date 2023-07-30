import Ecto.Query

alias AirDB.Booking
alias AirDB.Repo

IO.puts("=============================================================")

"""
>>> SELECT r.min_sum, r.max_sum, count(b.*)
      FROM bookings b
     RIGHT OUTER JOIN
         ( VALUES (      0,  100000), ( 100000,  200000),
                  ( 200000,  300000), ( 300000,  400000),
                  ( 400000,  500000), ( 500000,  600000),
                  ( 600000,  700000), ( 700000,  800000),
                  ( 800000,  900000), ( 900000, 1000000),
                  (1000000, 1100000), (1100000, 1200000),
                  (1200000, 1300000)
         ) AS r (min_sum, max_sum)
        ON b.total_amount >= r.min_sum AND b.total_amount < r.max_sum
     GROUP BY r.min_sum, r.max_sum
     ORDER BY r.min_sum
"""
|> IO.puts()

IO.puts("keyword example")

defmodule Queries09 do
  ranges = [
    {0, 100_000},
    {100_000, 200_000},
    {200_000, 300_000},
    {300_000, 400_000},
    {400_000, 500_000},
    {500_000, 600_000},
    {600_000, 700_000},
    {700_000, 800_000},
    {800_000, 900_000},
    {900_000, 1_000_000},
    {1_000_000, 1_100_000},
    {1_100_000, 1_200_000},
    {1_200_000, 1_300_000}
  ]

  values =
    ranges
    |> Enum.map_join(", ", fn {min_sum, max_sum} -> "(#{min_sum}, #{max_sum})" end)
    |> then(&"SELECT * FROM (VALUES #{&1}) AS values (min_sum, max_sum)")

  def query() do
    Booking
    |> with_cte("values", as: fragment(unquote(values)))
    |> join(:right, [b], v in "values",
      on: b.total_amount >= v.min_sum and b.total_amount < v.max_sum
    )
    |> group_by([b, v], [v.min_sum, v.max_sum])
    |> order_by([b, v], v.min_sum)
    |> select([b, v], map(v, [:min_sum, :max_sum]))
    |> select_merge([b, v], %{count: selected_as(count(b), :count)})
  end
end

Repo.all(Queries09.query()) |> IO.inspect(label: ">>> ")
