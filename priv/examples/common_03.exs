alias AirDB.Repo
alias AirDB.Seat

IO.puts(">>> INSERT INTO seats VALUES ('123', '1A', 'Business')")

%Seat{}
|> Seat.changeset(%{
  aircraft_code: "123",
  seat_no: "1A",
  fare_conditions: "Business"
})
|> Repo.insert()
|> IO.inspect(label: ">>> ")

"""
>>> INSERT INTO seats VALUES
('SU9', '1A', 'Business'),
('SU9', '1B', 'Business'),
('SU9', '10A', 'Economy'),
('SU9', '10B', 'Economy'),
('SU9', '10F', 'Economy'),
('SU9', '20F', 'Economy')
"""
|> IO.puts()

Repo.insert_all(Seat, [
  %{aircraft_code: "SU9", seat_no: "1A", fare_conditions: "Business"},
  %{aircraft_code: "SU9", seat_no: "2B", fare_conditions: "Business"},
  %{aircraft_code: "SU9", seat_no: "10A", fare_conditions: "Economy"},
  %{aircraft_code: "SU9", seat_no: "10B", fare_conditions: "Economy"},
  %{aircraft_code: "SU9", seat_no: "10F", fare_conditions: "Economy"},
  %{aircraft_code: "SU9", seat_no: "20F", fare_conditions: "Economy"}
])
|> IO.inspect(label: ">>> ")

"""
>>> INSERT INTO seats VALUES
      ('773', '1A', 'Business'),
      ('773', '1B', 'Business'),
      ('773', '10A', 'Economy'),
      ('773', '10B', 'Economy'),
      ('773', '10F', 'Economy'),
      ('773', '20F', 'Economy')
"""
|> IO.puts()

Repo.insert_all(Seat, [
  %{aircraft_code: "773", seat_no: "1A", fare_conditions: "Business"},
  %{aircraft_code: "773", seat_no: "2B", fare_conditions: "Business"},
  %{aircraft_code: "773", seat_no: "10A", fare_conditions: "Economy"},
  %{aircraft_code: "773", seat_no: "10B", fare_conditions: "Economy"},
  %{aircraft_code: "773", seat_no: "10F", fare_conditions: "Economy"},
  %{aircraft_code: "773", seat_no: "20F", fare_conditions: "Economy"}
])
|> IO.inspect(label: ">>> ")
