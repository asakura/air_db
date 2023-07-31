import Ecto.Query

alias AirDB.Aircraft
alias AirDB.Repo

IO.puts(
  ">>> INSERT INTO aircrafts (aircraft_code, model, range) VALUES ('SU9', 'Sukhoi SuperJet-100', 3000)"
)

%Aircraft{
  aircraft_code: "SU9",
  model: "Sukhoi SuperJet-100",
  range: 3000
}
|> Repo.insert()
|> IO.inspect(label: ">>> ")

Repo.all(from a in Aircraft, select: map(a, [:aircraft_code, :model, :range]))
|> IO.inspect(label: ">>> ")

"""
>>> INSERT INTO aircrafts (aircraft_code, model, range)
...   VALUES ('773', 'Boeing 777-300', 11100),
...          ('763', 'Boeing 767-300', 7900),
...          ('733', 'Boeing 737-300', 4200),
...          ('320', 'Airbus A320-200', 5700),
...          ('321', 'Airbus A321-200', 5600),
...          ('319', 'Airbus A319-100', 6700),
...          ('CN1', 'Cessna 208 Caravan', 1200),
...          ('CR2', 'Bombardier CRJ-200', 2700)
"""
|> IO.puts()

Repo.insert_all(Aircraft, [
  %{aircraft_code: "773", model: "Boeing 777-300", range: 11100},
  %{aircraft_code: "763", model: "Boeing 767-300", range: 7900},
  %{aircraft_code: "733", model: "Boeing 737-300", range: 4200},
  %{aircraft_code: "320", model: "Airbus A320-200", range: 5700},
  %{aircraft_code: "321", model: "Airbus A321-200", range: 5600},
  %{aircraft_code: "319", model: "Airbus A319-100", range: 6700},
  %{aircraft_code: "CN1", model: "Cessna 208 Caravan", range: 1200},
  %{aircraft_code: "CR2", model: "Bombardier CRJ-200", range: 2700}
])
|> IO.inspect(label: ">>> ")

Repo.all(from a in Aircraft, select: map(a, [:aircraft_code, :model, :range]))
|> IO.inspect(label: ">>> ")
