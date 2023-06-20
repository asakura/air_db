defmodule AirDB.Factory do
  use ExUnitProperties

  alias AirDB.Air
  alias AirDB.Aircraft
  alias AirDB.Airport
  alias AirDB.Booking
  alias AirDB.Flight
  alias AirDB.Generators, as: G
  alias AirDB.Seat
  alias AirDB.Ticket
  alias AirDB.TicketFlights

  def generator(Aircraft) do
    gen all aircraft_code <- string(:alphanumeric, length: 3),
            model <- G.Aircraft.model(),
            range <- integer(10..100) do
      %{aircraft_code: aircraft_code, model: model, range: range * 100}
    end
  end

  def generator(Airport) do
    gen all airport_code <- string(:alphanumeric, length: 3),
            airport_name <- G.Airport.name(),
            city <- string(:alphanumeric, length: 10),
            coordinates <- G.Airport.coordinates(),
            timezone <- G.Airport.timezone() do
      %{
        airport_code: airport_code,
        airport_name: airport_name,
        city: city,
        coordinates: coordinates,
        timezone: timezone
      }
    end
  end

  def generator(Seat) do
    gen all aircraft <- generator(Aircraft),
            seat_no <- G.Seat.seat_no(),
            fare_conditions <- G.Seat.fare_conditions() do
      %{aircraft: aircraft, seat_no: seat_no, fare_conditions: fare_conditions}
    end
  end

  def generator(Flight) do
    gen all departure_airport <- generator(Airport),
            arrival_airport <- generator(Airport),
            departure_airport.airport_code != arrival_airport.airport_code,
            scheduled_departure <- G.DateTime.datetime(),
            minutes_between <- integer(30..300),
            scheduled_arrival = DateTime.add(scheduled_departure, minutes_between * 60, :second),
            flight_id <- integer(1..90_000),
            flight_no <- string(:alphanumeric, length: 6),
            status <- G.Flight.status(),
            aircraft <- generator(Aircraft) do
      %{
        flight_id: flight_id,
        flight_no: flight_no,
        scheduled_departure: scheduled_departure,
        scheduled_arrival: scheduled_arrival,
        status: status,
        departure_airport: departure_airport,
        arrival_airport: arrival_airport,
        aircraft: aircraft
      }
    end
  end

  def generator(Booking) do
    gen all book_ref <- string(:alphanumeric, length: 6),
            book_date <- G.DateTime.datetime(),
            total_amount <- integer(100..10000),
            total_amount = total_amount * 100 do
      %{book_ref: book_ref, book_date: book_date, total_amount: total_amount}
    end
  end

  def generator(Ticket) do
    gen all ticket_no <- string(:alphanumeric, length: 13),
            passenger_id <- string(:alphanumeric, length: 20),
            passenger_name <- string(:ascii, length: 10),
            # TODO
            contact_data = %{},
            booking <- generator(Booking) do
      %{
        ticket_no: ticket_no,
        passenger_id: passenger_id,
        passenger_name: passenger_name,
        contact_data: contact_data,
        booking: booking
      }
    end
  end

  def generator(TicketFlights) do
    gen all fare_conditions <- G.Seat.fare_conditions(),
            amount <- integer(100..10000),
            amount = amount * 100,
            ticket <- generator(Ticket),
            flight <- generator(Flight) do
      %{fare_conditions: fare_conditions, amount: amount, ticket: ticket, flight: flight}
    end
  end

  def build(generator_name, attrs \\ []) do
    1 |> build_list(generator_name, attrs) |> List.first()
  end

  def build_list(count, generator_name, attrs \\ []) do
    generator_name
    |> generator()
    |> Enum.take(count)
    |> Enum.map(fn params ->
      params
      |> Map.merge(Enum.into(attrs, %{}))
      |> Enum.filter(fn {_key, value} -> not is_nil(value) end)
      |> Enum.into(%{})
    end)
  end

  def fixture(schema, attrs \\ [])

  def fixture(Aircraft, attrs) do
    {:ok, aircraft} =
      Aircraft
      |> build(attrs)
      |> Air.create_aircraft()

    aircraft
  end

  def fixture(Airport, attrs) do
    {:ok, airport} =
      Airport
      |> build(attrs)
      |> Air.create_airport()

    airport
  end

  def fixture(Seat, attrs) do
    {:ok, seat} =
      Seat
      |> build(attrs)
      |> Air.create_seat()

    seat
  end

  def fixture(Flight, attrs) do
    {:ok, flight} =
      Flight
      |> build(attrs)
      |> Air.create_flight()

    flight
  end

  def fixture(Booking, attrs) do
    {:ok, booking} =
      Booking
      |> build(attrs)
      |> Air.create_booking()

    booking
  end

  def fixture(Ticket, attrs) do
    {:ok, ticket} =
      Ticket
      |> build(attrs)
      |> Air.create_ticket()

    ticket
  end

  def fixture(TicketFlights, attrs) do
    {:ok, flight_segment} =
      TicketFlights
      |> build(attrs)
      |> Air.create_ticket_flights()

    flight_segment
  end
end
