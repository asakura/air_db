defmodule AirDB.Air do
  alias AirDB.Aircraft
  alias AirDB.Airport
  alias AirDB.BoardingPass
  alias AirDB.Booking
  alias AirDB.Flight
  alias AirDB.Repo
  alias AirDB.Seat
  alias AirDB.Ticket
  alias AirDB.TicketFlights

  def create_aircraft(attrs \\ %{}) do
    %Aircraft{}
    |> Aircraft.changeset(attrs)
    |> Repo.insert()
  end

  def list_aircrafts() do
    Repo.all(Aircraft)
  end

  def create_airport(attrs \\ %{}) do
    %Airport{}
    |> Airport.changeset(attrs)
    |> Repo.insert()
  end

  def list_airports() do
    Repo.all(Airport)
  end

  def create_seat(attrs \\ %{}) do
    %Seat{}
    |> Seat.changeset(attrs)
    |> Repo.insert()
  end

  def list_seats() do
    Repo.all(Seat)
  end

  def create_flight(attrs \\ %{}) do
    %Flight{}
    |> Flight.changeset(attrs)
    |> Repo.insert()
  end

  def list_flights() do
    Repo.all(Flight)
  end

  def create_booking(attrs \\ %{}) do
    %Booking{}
    |> Booking.changeset(attrs)
    |> Repo.insert()
  end

  def list_bookings() do
    Repo.all(Booking)
  end

  def create_ticket(attrs \\ %{}) do
    %Ticket{}
    |> Ticket.changeset(attrs)
    |> Repo.insert()
  end

  def list_tickets() do
    Repo.all(Ticket)
  end

  def create_ticket_flights(attrs \\ %{}) do
    %TicketFlights{}
    |> TicketFlights.changeset(attrs)
    |> Repo.insert()
  end

  def list_ticket_flights() do
    Repo.all(TicketFlights)
  end

  def create_boarding_pass(attrs \\ %{}) do
    %BoardingPass{}
    |> BoardingPass.changeset(attrs)
    |> Repo.insert()
  end

  def list_boarding_passes() do
    Repo.all(BoardingPass)
  end
end
