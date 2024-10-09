defmodule FCM.Data.TransportTest do
  use ExUnit.Case, async: true

  alias FCM.Data.Transport

  doctest Transport

  describe "parse" do
    test "Flight SVQ 2023-01-05 20:40 -> BCN 22:10" do
      assert {:ok,
              %Transport{
                kind: :flight,
                iata_from: "SVQ",
                date_time_departure: ~N[2023-01-05 20:40:00],
                iata_to: "BCN",
                date_time_arrival: ~N[2023-01-05 22:10:00]
              }} == Transport.parse("Flight SVQ 2023-01-05 20:40 -> BCN 22:10")
    end

    test "Train BCN 2023-01-05 20:40 -> MAD 22:10" do
      assert {:ok,
              %Transport{
                kind: :train,
                iata_from: "BCN",
                date_time_departure: ~N[2023-01-05 20:40:00],
                iata_to: "MAD",
                date_time_arrival: ~N[2023-01-05 22:10:00]
              }} == Transport.parse("Train BCN 2023-01-05 20:40 -> MAD 22:10")
    end

    test "Bus MAD 2023-01-05 20:40 -> BCN 22:10" do
      {:error, _} = Transport.parse("Bus MAD 2023-01-05 20:40 -> BCN 22:10")
    end

    test "Flight SVQ 2023-01-05 20:40 -> BCN 22:10 with whitespace" do
      assert {:ok,
              %Transport{
                kind: :flight,
                iata_from: "SVQ",
                date_time_departure: ~N[2023-01-05 20:40:00],
                iata_to: "BCN",
                date_time_arrival: ~N[2023-01-05 22:10:00]
              }} == Transport.parse(" Flight SVQ   2023-01-05 20:40 ->   BCN 22:10 ")
    end
  end
end
