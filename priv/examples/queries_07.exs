import Ecto.Query

alias AirDB.Aircraft
alias AirDB.Repo
alias AirDB.Route

IO.puts("=============================================================")

"""
>>> SELECT r.aircraft_code, a.model, count(*) AS num_routes
      FROM routes r
      JOIN aircrafts a ON r.aircraft_code = a.aircraft_code
     GROUP BY 1, 2
     ORDER BY 3 DESC
"""
|> IO.puts()

IO.puts("keyword example")

query =
  from r in Route,
    join: a in assoc(r, :aircraft),
    group_by: [a.aircraft_code, a.model],
    order_by: [desc: selected_as(:num_routes)],
    select: map(a, [:aircraft_code, :model]),
    select_merge: %{num_routes: selected_as(count(), :num_routes)}

Repo.all(query) |> IO.inspect(label: ">>> ")

IO.puts("macro example")

Route
|> join(:inner, [r], a in assoc(r, :aircraft))
|> group_by([r, a], [a.aircraft_code, a.model])
|> order_by(desc: selected_as(:num_routes))
|> select([r, a], map(a, [:aircraft_code, :model]))
|> select_merge(%{num_routes: selected_as(count(), :num_routes)})
|> Repo.all()
|> IO.inspect(label: ">>> ")

IO.puts("=============================================================")

"""
>>> SELECT a.aircraft_code AS a_code,
           a.model,
           r.aircraft_code AS r_code,
           count(r.aircraft_code) AS num_routes
      FROM aircrafts a
      LEFT OUTER JOIN routes r ON r.aircraft_code = a.aircraft_code
     GROUP BY 1, 2, 3
     ORDER BY 4 DESC
"""
|> IO.puts()

IO.puts("keyword example")

query =
  from a in Aircraft,
    left_join: r in assoc(a, :routes),
    group_by: [a.aircraft_code, a.model, r.aircraft_code],
    order_by: [desc: selected_as(:num_routes)],
    select: %{a_code: a.aircraft_code, model: a.model},
    select_merge: %{r_code: r.aircraft_code},
    select_merge: %{num_routes: selected_as(count(r.aircraft_code), :num_routes)}

Repo.all(query) |> IO.inspect(label: ">>> ")

IO.puts("macro example")

Aircraft
|> join(:left, [a], r in assoc(a, :routes))
|> group_by([a, r], [a.aircraft_code, a.model, r.aircraft_code])
|> order_by(desc: selected_as(:num_routes))
|> select([a], %{a_code: a.aircraft_code, model: a.model})
|> select_merge([a, r], %{r_code: r.aircraft_code})
|> select_merge([a, r], %{num_routes: selected_as(count(r.aircraft_code), :num_routes)})
|> Repo.all()
|> IO.inspect(label: ">>> ")

IO.puts("=============================================================")

"""
>>> SELECT a.aircraft_code AS a_code,
           a.model,
           r.aircraft_code AS r_code,
           count(r.aircraft_code) AS num_routes
      FROM routes r
      RIGHT OUTER JOIN aircrafts a ON r.aircraft_code = a.aircraft_code
      GROUP BY 1, 2, 3
      ORDER BY 4 DESC
"""
|> IO.puts()

IO.puts("keyword example")

query =
  from r in Route,
    right_join: a in assoc(r, :aircraft),
    group_by: [a.aircraft_code, a.model, r.aircraft_code],
    order_by: [desc: selected_as(:num_routes)],
    select: %{a_code: a.aircraft_code, model: a.model},
    select_merge: %{r_code: r.aircraft_code},
    select_merge: %{num_routes: selected_as(count(r.aircraft_code), :num_routes)}

Repo.all(query) |> IO.inspect(label: ">>> ")

IO.puts("macro example")

Route
|> join(:right, [r], a in assoc(r, :aircraft))
|> group_by([r, a], [a.aircraft_code, a.model, r.aircraft_code])
|> order_by(desc: selected_as(:num_routes))
|> select([r, a], map(a, [:aircraft_code, :model]))
|> select_merge([r, a], map(r, [:aircraft_code]))
|> select_merge([r, a], %{num_routes: selected_as(count(r.aircraft_code), :num_routes)})
|> Repo.all()
|> IO.inspect(label: ">>> ")
