defmodule AirDB.AirAirportTest do
  use AirDB.DataCase, async: true

  alias AirDB.Air
  alias AirDB.Airport

  describe "create_airport/1" do
    @valid_attrs %{
      airport_code: "KJA",
      airport_name: "Yemelyanovo Airport",
      city: "Krasnoyarsk",
      coordinates: %Postgrex.Point{x: 92.493301391602, y: 56.172901153564},
      timezone: "Asia/Krasnoyarsk"
    }

    test "with valid data inserts airport" do
      assert {:ok, %Airport{airport_code: airport_code} = airport} =
               Air.create_airport(@valid_attrs)

      assert airport.airport_code == "KJA"
      assert airport.airport_name == "Yemelyanovo Airport"
      assert airport.city == "Krasnoyarsk"
      assert airport.coordinates == %Postgrex.Point{x: 92.493301391602, y: 56.172901153564}
      assert airport.timezone == "Asia/Krasnoyarsk"

      assert [%Airport{airport_code: ^airport_code}] = Air.list_airports()
    end

    test "with invalid data does not insert airport" do
      assert {:error, _changeset} = Air.create_airport(%{})
      assert Air.list_airports() == []
    end

    test "enforces unique airport codes" do
      assert {:ok, %Airport{airport_code: airport_code}} = Air.create_airport(@valid_attrs)
      assert {:error, changeset} = Air.create_airport(@valid_attrs)

      assert %{airport_code: ["has already been taken"]} = errors_on(changeset)

      assert [%Airport{airport_code: ^airport_code}] = Air.list_airports()
    end

    test "accepts only 3 bytes long airport codes" do
      attrs = Map.put(@valid_attrs, :airport_code, String.duplicate("a", 10))
      {:error, changeset} = Air.create_airport(attrs)

      assert %{airport_code: ["should be 3 byte(s)"]} = errors_on(changeset)
      assert Air.list_airports() == []
    end
  end
end
