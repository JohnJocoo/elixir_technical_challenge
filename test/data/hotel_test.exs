defmodule FCM.Data.HotelTest do
  use ExUnit.Case, async: true

  alias FCM.Data.Hotel

  doctest Hotel

  describe "parse" do
    test "Hotel BCN 2023-01-05 -> 2023-01-10" do
      assert {:ok, %Hotel{
        iata: "BCN",
        date_first: ~D[2023-01-05],
        date_last: ~D[2023-01-10]
        }} == Hotel.parse("Hotel BCN 2023-01-05 -> 2023-01-10")
    end

    test "Hotel BCN 2023-01-05 -> 2023-01-10 with whitespace" do
      assert {:ok, %Hotel{
        iata: "BCN",
        date_first: ~D[2023-01-05],
        date_last: ~D[2023-01-10]
        }} == Hotel.parse(" Hotel BCN   2023-01-05 ->   2023-01-10 ")
    end

    test "Hotel por 2023-01-05 -> 2023-01-10" do
      {:error, _} = Hotel.parse("Hotel por 2023-01-05 -> 2023-01-10")
    end

    test "Hotel POR today -> 2025-01-10" do
      {:error, _} = Hotel.parse("Hotel POR today -> 2025-01-10")
    end
  end
end
