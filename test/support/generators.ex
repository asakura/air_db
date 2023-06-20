defmodule AirDB.Generators.DateTime do
  use ExUnitProperties

  def date() do
    gen all year <- integer(1970..2050),
            month <- integer(1..12),
            day <- integer(1..31),
            match?({:ok, _}, Date.from_erl({year, month, day})) do
      Date.from_erl!({year, month, day})
    end
  end

  def time() do
    gen all hour <- integer(0..23),
            minute <- integer(0..59),
            second <- integer(0..59) do
      Time.from_erl!({hour, minute, second})
    end
  end

  def naive_datetime() do
    gen all date <- date(),
            time <- time() do
      NaiveDateTime.new!(date, time)
    end
  end

  def datetime() do
    gen all naive_datetime <- naive_datetime() do
      DateTime.from_naive!(naive_datetime, "Etc/UTC")
    end
  end
end

defmodule AirDB.Generators.Aircraft do
  use ExUnitProperties

  def model() do
    gen all model <- string(:alphanumeric, length: 10) do
      "Aircraft #{model}"
    end
  end
end

defmodule AirDB.Generators.Airport do
  use ExUnitProperties

  @timezones [
    "Europe/Volgograd",
    "Asia/Omsk",
    "Europe/Samara",
    "Asia/Chita",
    "Asia/Novosibirsk",
    "Asia/Krasnoyarsk",
    "Asia/Magadan",
    "Asia/Kamchatka",
    "Asia/Anadyr",
    "Asia/Novokuznetsk",
    "Asia/Irkutsk",
    "Asia/Vladivostok",
    "Europe/Kaliningrad",
    "Asia/Sakhalin",
    "Asia/Yakutsk",
    "Europe/Moscow",
    "Asia/Yekaterinburg"
  ]

  def name() do
    gen all name <- string(:ascii, length: 10) do
      "Airport #{name}"
    end
  end

  def coordinates() do
    gen all coordinate_x <- float(min: 20, max: 177),
            coordinate_y <- float(min: 42, max: 69) do
      %Postgrex.Point{x: coordinate_x, y: coordinate_y}
    end
  end

  def timezone() do
    gen all timezone <- member_of(@timezones) do
      timezone
    end
  end
end

defmodule AirDB.Generators.Seat do
  use ExUnitProperties

  @fare_conditions [
    "Economy",
    "Comfort",
    "Business"
  ]

  def seat_no() do
    gen all row <- integer(1..100),
            seat <- member_of(["A", "B", "C", "D", "F", "G"]) do
      "#{row}#{seat}"
    end
  end

  def fare_conditions() do
    gen all fare_condition <- member_of(@fare_conditions) do
      fare_condition
    end
  end
end

defmodule AirDB.Generators.Flight do
  use ExUnitProperties

  @flight_statuses [
    "On Time",
    "Delayed",
    "Departed",
    "Arrived",
    "Scheduled",
    "Cancelled"
  ]

  def status() do
    gen all status <- member_of(@flight_statuses) do
      status
    end
  end
end
