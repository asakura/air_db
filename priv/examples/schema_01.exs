alias AirDB.{Repo, Aircraft, Airport, Seat, Flight, Booking, Ticket, BoardingPass, TicketFlights}

Repo.insert(%Seat{
  seat_no: "5D",
  fare_conditions: "Business",
  aircraft: %Aircraft{
    aircraft_code: "773",
    model: "Boeing 777-300",
    range: 11100
  }
})

{:ok, flight_segment} =
  Repo.insert(%TicketFlights{
    fare_conditions: "Business",
    amount: Decimal.from_float(106_100.00),
    ticket: %Ticket{
      ticket_no: "0005435138989",
      booking: %Booking{
        book_ref: "00006A",
        book_date: ~U[2016-11-05 02:02:00+00:00],
        total_amount: Decimal.from_float(106_100.00)
      },
      passenger_id: "9960 592684",
      passenger_name: "EVDOKIYA FOMINA",
      contact_data: %{"email" => "fominae.06021964@postgrespro.ru", "phone" => "+70106072670"}
    },
    flight: %Flight{
      flight_id: 2880,
      flight_no: "PG0216",
      scheduled_departure: ~U[2017-09-14 11:10:00+00:00],
      scheduled_arrival: ~U[2017-09-14 12:15:00+00:00],
      departure_airport: %Airport{
        airport_code: "YKS",
        airport_name: "Yakutsk Airport",
        city: "Yakutsk",
        coordinates: %Postgrex.Point{x: 129.77099609375, y: 62.093299865722656},
        timezone: "Asia/Yakutsk"
      },
      arrival_airport: %Airport{
        airport_code: "GOJ",
        airport_name: "Nizhny Novgorod Strigino International Airport",
        city: "Nizhniy Novgorod",
        coordinates: %Postgrex.Point{x: 43.784000396729, y: 56.230098724365},
        timezone: "Europe/Moscow"
      },
      status: "Scheduled",
      aircraft: %Aircraft{
        aircraft_code: "763",
        model: "Boeing 767-300",
        range: 7900
      },
      actual_departure: nil,
      actual_arrival: nil
    }
  })

Repo.insert(%BoardingPass{
  ticket_no: flight_segment.ticket_no,
  flight_id: 2880,
  boarding_no: 17,
  seat_no: "20C"
})
