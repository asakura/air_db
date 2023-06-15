NimbleCSV.define(TSVParser, separator: "\t", escape: "\"")

alias AirDB.Aircraft
alias AirDB.Airport
alias AirDB.Repo
alias AirDB.Booking
alias AirDB.Flight
alias AirDB.Seat
alias AirDB.Ticket
alias AirDB.TicketFlights
alias AirDB.BoardingPass

defmodule RepoSeeder do
  def populate do
    aircrafts = Task.async(fn -> populate_aircrafts() end)
    airports = Task.async(fn -> populate_airports() end)

    Task.await(aircrafts)
    Task.await(airports)

    bookings = Task.async(fn -> populate_bookings() end)
    flights = Task.async(fn -> populate_flights() end)
    seats = Task.async(fn -> populate_seats() end)

    Task.await(seats, 60_000)
    Task.await(flights, 60_000)
    Task.await(bookings, 60_000)

    populate_tickets()

    populate_ticket_flights()

    populate_boarding_passes()
  end

  def bulk_insert(filename, to_changes, schema, batch_size \\ 10_000) do
    Repo.transaction(
      fn ->
        filename
        |> File.stream!()
        |> TSVParser.parse_stream(skip_headers: false)
        |> Stream.map(to_changes)
        |> Stream.chunk_every(batch_size)
        |> Stream.each(fn chunk -> Repo.insert_all(schema, chunk) end)
        |> Stream.run()
      end,
      timeout: :infinity
    )
  end

  def populate_aircrafts do
    bulk_insert(
      "priv/repo/aircrafts.tsv",
      fn [aircraft_code, model, range] ->
        Aircraft.changeset(%Aircraft{}, %{
          aircraft_code: aircraft_code,
          model: model,
          range: range
        }).changes
      end,
      Aircraft,
      21_000
    )
  end

  def populate_airports do
    bulk_insert(
      "priv/repo/airports.tsv",
      fn [airport_code, airport_name, city, coordinates, timezone] ->
        Airport.changeset(%Airport{}, %{
          airport_code: airport_code,
          airport_name: airport_name,
          city: city,
          coordinates: coordinates,
          timezone: timezone
        }).changes
      end,
      Airport,
      13_000
    )
  end

  def populate_bookings do
    bulk_insert(
      "priv/repo/bookings.tsv",
      fn [book_ref, book_date, total_amount] ->
        Booking.changeset(%Booking{}, %{
          book_ref: book_ref,
          book_date: book_date,
          total_amount: total_amount
        }).changes
      end,
      Booking,
      21_000
    )
  end

  def populate_flights do
    bulk_insert(
      "priv/repo/flights.tsv",
      fn [
           flight_id,
           flight_no,
           scheduled_departure,
           scheduled_arrival,
           departure_airport_code,
           arrival_airport_code,
           status,
           aircraft_code,
           actual_departure,
           actual_arrival
         ] ->
        Flight.changeset(%Flight{}, %{
          flight_id: flight_id,
          flight_no: flight_no,
          scheduled_departure: scheduled_departure,
          scheduled_arrival: scheduled_arrival,
          departure_airport_code: departure_airport_code,
          arrival_airport_code: arrival_airport_code,
          status: status,
          aircraft_code: aircraft_code,
          actual_departure: actual_departure,
          actual_arrival: actual_arrival
        }).changes
      end,
      Flight,
      6_500
    )
  end

  def populate_seats do
    bulk_insert(
      "priv/repo/seats.tsv",
      fn [
           aircraft_code,
           seat_no,
           fare_conditions
         ] ->
        Seat.changeset(%Seat{}, %{
          aircraft_code: aircraft_code,
          seat_no: seat_no,
          fare_conditions: fare_conditions
        }).changes
      end,
      Seat,
      21_600
    )
  end

  def populate_tickets do
    bulk_insert(
      "priv/repo/tickets.tsv",
      fn [
           ticket_no,
           book_ref,
           passenger_id,
           passenger_name,
           contact_data
         ] ->
        Ticket.changeset(%Ticket{}, %{
          ticket_no: ticket_no,
          book_ref: book_ref,
          passenger_id: passenger_id,
          passenger_name: passenger_name,
          contact_data: contact_data
        }).changes
      end,
      Ticket,
      13_000
    )
  end

  def populate_ticket_flights do
    bulk_insert(
      "priv/repo/ticket_flights.tsv",
      fn [
           ticket_no,
           flight_id,
           fare_conditions,
           amount
         ] ->
        TicketFlights.changeset(%TicketFlights{}, %{
          ticket_no: ticket_no,
          flight_id: flight_id,
          fare_conditions: fare_conditions,
          amount: amount
        }).changes
      end,
      TicketFlights,
      16_250
    )
  end

  def populate_boarding_passes do
    bulk_insert(
      "priv/repo/boarding_passes.tsv",
      fn [
           ticket_no,
           flight_id,
           boarding_no,
           seat_no
         ] ->
        BoardingPass.changeset(%BoardingPass{}, %{
          ticket_no: ticket_no,
          flight_id: flight_id,
          boarding_no: boarding_no,
          seat_no: seat_no
        }).changes
      end,
      BoardingPass,
      16_250
    )
  end
end

RepoSeeder.populate()
