defmodule FCM.Data.TripTest do
  use ExUnit.Case, async: true

  alias FCM.Data.Trip
  alias FCM.Data.Transport
  alias FCM.Data.Hotel

  describe "new" do
    test "empty" do
      assert %Trip{segments: []} == Trip.new([])
    end

    test "flight" do
      assert %Trip{segments: [
        %Transport{
          kind: :flight,
          iata_from: "SVQ",
          date_time_departure: ~N[2023-01-05 20:40:00],
          iata_to: "BCN",
          date_time_arrival: ~N[2023-01-05 22:10:00]
        }
      ]} == Trip.new([%Transport{
        kind: :flight,
        iata_from: "SVQ",
        date_time_departure: ~N[2023-01-05 20:40:00],
        iata_to: "BCN",
        date_time_arrival: ~N[2023-01-05 22:10:00]
      }])
    end
  end

  describe "iata_from" do
    test "empty" do
      assert nil == Trip.iata_from(%Trip{segments: []})
    end

    test "flight" do
      assert "SVQ" == Trip.iata_from(%Trip{segments: [
        %Transport{
          kind: :flight,
          iata_from: "SVQ",
          date_time_departure: ~N[2023-01-05 20:40:00],
          iata_to: "BCN",
          date_time_arrival: ~N[2023-01-05 22:10:00]
        }
      ]})
    end

    test "two flights" do
      assert "SVQ" == Trip.iata_from(%Trip{segments: [
        %Transport{
          kind: :flight,
          iata_from: "SVQ",
          date_time_departure: ~N[2023-01-05 20:40:00],
          iata_to: "BCN",
          date_time_arrival: ~N[2023-01-05 22:10:00]
        },
        %Transport{
          kind: :flight,
          iata_from: "BCN",
          date_time_departure: ~N[2023-01-06 20:40:00],
          iata_to: "POR",
          date_time_arrival: ~N[2023-01-06 22:10:00]
        }
      ]})
    end
  end

  describe "iata_final" do
    test "empty" do
      assert nil == Trip.iata_final(%Trip{segments: []})
    end

    test "flight" do
      assert "BCN" == Trip.iata_final(%Trip{segments: [
        %Transport{
          kind: :flight,
          iata_from: "SVQ",
          date_time_departure: ~N[2023-01-05 20:40:00],
          iata_to: "BCN",
          date_time_arrival: ~N[2023-01-05 22:10:00]
        }
      ]})
    end

    test "two flights" do
      assert "POR" == Trip.iata_final(%Trip{segments: [
        %Transport{
          kind: :flight,
          iata_from: "SVQ",
          date_time_departure: ~N[2023-01-05 20:40:00],
          iata_to: "BCN",
          date_time_arrival: ~N[2023-01-05 22:10:00]
        },
        %Transport{
          kind: :flight,
          iata_from: "BCN",
          date_time_departure: ~N[2023-02-06 20:40:00],
          iata_to: "POR",
          date_time_arrival: ~N[2023-02-06 22:10:00]
        }
      ]})
    end
  end

  describe "iatas_staying" do
    test "empty" do
      assert [] == Trip.iatas_staying(%Trip{segments: []})
    end

    test "flight" do
      assert ["BCN"] == Trip.iatas_staying(%Trip{segments: [
        %Transport{
          kind: :flight,
          iata_from: "SVQ",
          date_time_departure: ~N[2023-01-05 20:40:00],
          iata_to: "BCN",
          date_time_arrival: ~N[2023-01-05 22:10:00]
        }
      ]})
    end

    test "two flights" do
      assert ["BCN", "POR"] == Trip.iatas_staying(%Trip{segments: [
        %Transport{
          kind: :flight,
          iata_from: "SVQ",
          date_time_departure: ~N[2023-01-05 20:40:00],
          iata_to: "BCN",
          date_time_arrival: ~N[2023-01-05 22:10:00]
        },
        %Transport{
          kind: :flight,
          iata_from: "BCN",
          date_time_departure: ~N[2023-02-06 20:40:00],
          iata_to: "POR",
          date_time_arrival: ~N[2023-02-06 22:10:00]
        }
      ]})
    end

    test "two flights, change" do
      assert ["POR"] == Trip.iatas_staying(%Trip{segments: [
        %Transport{
          kind: :flight,
          iata_from: "SVQ",
          date_time_departure: ~N[2023-01-05 20:40:00],
          iata_to: "BCN",
          date_time_arrival: ~N[2023-01-05 22:10:00]
        },
        %Transport{
          kind: :flight,
          iata_from: "BCN",
          date_time_departure: ~N[2023-01-05 23:00:00],
          iata_to: "POR",
          date_time_arrival: ~N[2023-01-05 23:50:00]
        }
      ]})
    end

    test "two flights, change with hotel" do
      assert ["BCN", "POR"] == Trip.iatas_staying(%Trip{segments: [
        %Transport{
          kind: :flight,
          iata_from: "SVQ",
          date_time_departure: ~N[2023-01-05 15:40:00],
          iata_to: "BCN",
          date_time_arrival: ~N[2023-01-05 16:00:00]
        },
        %Hotel{
          iata: "BCN",
          date_first: ~D[2023-01-05],
          date_last: ~D[2023-01-10]
        },
        %Transport{
          kind: :flight,
          iata_from: "BCN",
          date_time_departure: ~N[2023-01-05 20:00:00],
          iata_to: "POR",
          date_time_arrival: ~N[2023-01-05 21:00:00]
        }
      ]})
    end

    test "round trip" do
      assert ["BCN"] == Trip.iatas_staying(%Trip{segments: [
        %Transport{
          kind: :flight,
          iata_from: "SVQ",
          date_time_departure: ~N[2023-01-05 20:40:00],
          iata_to: "BCN",
          date_time_arrival: ~N[2023-01-05 22:10:00]
        },
        %Transport{
          kind: :flight,
          iata_from: "BCN",
          date_time_departure: ~N[2023-02-06 20:40:00],
          iata_to: "SVQ",
          date_time_arrival: ~N[2023-02-06 22:10:00]
        }
      ]})
    end
  end
end
