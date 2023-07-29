import Ecto.Query

alias AirDB.Aircraft
alias AirDB.Repo

IO.puts("=============================================================")

"""
>>> SELECT model, range,
      CASE WHEN range < 2000 THEN 'Close range'
           WHEN range < 5000 THEN 'Middle range'
           ELSE 'Long range'
       END AS type
      FROM aircrafts
     ORDER BY model
"""
|> IO.puts()

IO.puts("keyword example")

case_expr =
  dynamic(
    [q],
    fragment(
      """
      CASE WHEN ? < 2000 THEN 'Close range'
      WHEN ? < 5000 THEN 'Middle range'
      ELSE 'Long range'
      END
      """,
      q.range,
      q.range
    )
  )

query =
  from a in Aircraft,
    order_by: a.model,
    select: map(a, [:model, :range]),
    select_merge: ^%{type: case_expr}

Repo.all(query) |> IO.inspect(label: ">>> ")

IO.puts("macro example")

Aircraft
|> order_by([a], a.model)
|> select([a], map(a, [:model, :range]))
|> select_merge([a], ^%{type: case_expr})
|> Repo.all()
|> IO.inspect(label: ">>> ")
