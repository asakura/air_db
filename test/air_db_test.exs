defmodule AirDBTest do
  use ExUnit.Case
  doctest AirDB

  test "greets the world" do
    assert AirDB.hello() == :world
  end
end
