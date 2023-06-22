defmodule AirDB.AirAircraftTest do
  use AirDB.DataCase, async: true

  alias AirDB.Air
  alias AirDB.Aircraft
  alias AirDB.Seat

  describe "create_aircraft/1" do
    @valid_attrs %{
      aircraft_code: "773",
      model: "Boeing 773-300",
      range: 9000
    }

    test "with valid data inserts aircraft" do
      assert {:ok, %Aircraft{aircraft_code: aircraft_code} = aircraft} =
               Air.create_aircraft(@valid_attrs)

      assert aircraft.aircraft_code == "773"
      assert aircraft.model == "Boeing 773-300"
      assert aircraft.range == 9000

      assert [%Aircraft{aircraft_code: ^aircraft_code}] = Air.list_aircrafts()
    end

    test "with invalid data does not insert aircraft" do
      assert {:error, _changeset} = Air.create_aircraft(%{})
      assert Air.list_aircrafts() == []
    end

    test "enforces unique aircraft codes" do
      assert {:ok, %Aircraft{aircraft_code: aircraft_code}} = Air.create_aircraft(@valid_attrs)
      assert {:error, changeset} = Air.create_aircraft(@valid_attrs)

      assert %{aircraft_code: ["has already been taken"]} = errors_on(changeset)

      assert [%Aircraft{aircraft_code: ^aircraft_code}] = Air.list_aircrafts()
    end

    test "accepts only 3 bytes long aircraft codes" do
      attrs = Map.put(@valid_attrs, :aircraft_code, String.duplicate("a", 10))
      {:error, changeset} = Air.create_aircraft(attrs)

      assert %{aircraft_code: ["should be 3 byte(s)"]} = errors_on(changeset)
      assert Air.list_aircrafts() == []
    end

    test "checks that range is greater than zero" do
      attrs = Map.put(@valid_attrs, :range, 0)
      {:error, changeset} = Air.create_aircraft(attrs)

      assert %{range: ["should be greater than 0"]} = errors_on(changeset)
      assert Air.list_aircrafts() == []
    end

    test "casts seats from provided parameters" do
      attrs = Map.put(@valid_attrs, :seats, build_list(3, Seat, aircraft: nil))

      assert {:ok, %Aircraft{aircraft_code: aircraft_code} = aircraft} =
               Air.create_aircraft(attrs)

      assert [%Aircraft{aircraft_code: ^aircraft_code}] = Air.list_aircrafts()

      assert [
               %Seat{aircraft_code: ^aircraft_code},
               %Seat{aircraft_code: ^aircraft_code},
               %Seat{aircraft_code: ^aircraft_code}
             ] = Repo.preload(aircraft, :seats).seats
    end
  end
end
