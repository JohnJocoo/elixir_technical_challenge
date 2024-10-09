defmodule FCMTest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  test "input.txt" do
    assert capture_io(fn ->
      assert FCM.print_trips_from_file("input.txt") == :ok
    end) =~ """
    TRIP to BCN
    Flight from SVQ to BCN at 2023-01-05 20:40 to 22:10
    Hotel at BCN on 2023-01-05 to 2023-01-10
    Flight from BCN to SVQ at 2023-01-10 10:30 to 11:50

    TRIP to MAD
    Train from SVQ to MAD at 2023-02-15 09:30 to 11:00
    Hotel at MAD on 2023-02-15 to 2023-02-17
    Train from MAD to SVQ at 2023-02-17 17:00 to 19:30

    TRIP to NYC, BOS
    Flight from SVQ to BCN at 2023-03-02 06:40 to 09:10
    Flight from BCN to NYC at 2023-03-02 15:00 to 22:45
    Flight from NYC to BOS at 2023-03-06 08:00 to 09:25
    """
  end

  test "one_direction_flight.txt" do
    assert capture_io(fn ->
      assert FCM.print_trips_from_file("test/inputs/one_direction_flight.txt") == :ok
    end) =~ """
    TRIP to BCN
    Flight from POR to BCN at 2024-11-09 09:00 to 11:20
    """
  end

  test "one_direction_train.txt" do
    assert capture_io(fn ->
      assert FCM.print_trips_from_file("test/inputs/one_direction_train.txt") == :ok
    end) =~ """
    TRIP to LSB
    Train from POR to LSB at 2024-11-09 09:00 to 11:55
    """
  end

  test "round_trip_flight.txt" do
    assert capture_io(fn ->
      assert FCM.print_trips_from_file("test/inputs/round_trip_flight.txt") == :ok
    end) =~ """
    TRIP to BCN
    Flight from POR to BCN at 2024-11-09 09:00 to 11:20
    Flight from BCN to POR at 2024-11-16 17:00 to 19:10
    """
  end

  test "round_trip_hotel.txt" do
    assert capture_io(fn ->
      assert FCM.print_trips_from_file("test/inputs/round_trip_hotel.txt") == :ok
    end) =~ """
    TRIP to BCN
    Flight from POR to BCN at 2024-11-09 09:00 to 11:20
    Hotel at BCN on 2024-11-09 to 2024-11-16
    Flight from BCN to POR at 2024-11-16 17:00 to 19:10
    """
  end

  test "round_trip_hotel_separate.txt" do
    assert capture_io(fn ->
      assert FCM.print_trips_from_file("test/inputs/round_trip_hotel_separate.txt") == :ok
    end) =~ """
    TRIP to BCN
    Flight from POR to BCN at 2024-11-09 09:00 to 11:20
    Hotel at BCN on 2024-11-09 to 2024-11-16
    Flight from BCN to POR at 2024-11-16 17:00 to 19:10
    """
  end

  test "two_iatas.txt" do
    assert capture_io(fn ->
      assert FCM.print_trips_from_file("test/inputs/two_iatas.txt") == :ok
    end) =~ """
    TRIP to BCN, PAR
    Flight from POR to BCN at 2024-11-09 09:00 to 11:20
    Hotel at BCN on 2024-11-09 to 2024-11-16
    Flight from BCN to PAR at 2024-11-16 17:00 to 19:10
    """
  end

  test "two_iatas2.txt" do
    assert capture_io(fn ->
      assert FCM.print_trips_from_file("test/inputs/two_iatas2.txt") == :ok
    end) =~ """
    TRIP to BCN, PAR
    Flight from POR to BCN at 2024-11-09 09:00 to 11:20
    Hotel at BCN on 2024-11-09 to 2024-11-16
    Flight from BCN to PAR at 2024-11-16 17:00 to 20:10
    Flight from PAR to POR at 2024-11-19 12:00 to 16:10
    """
  end

  test "two_stays.txt" do
    assert capture_io(fn ->
      assert FCM.print_trips_from_file("test/inputs/two_stays.txt") == :ok
    end) =~ """
    TRIP to BCN
    Flight from POR to BCN at 2024-11-09 09:00 to 11:20
    Hotel at BCN on 2024-11-09 to 2024-11-13
    Hotel at BCN on 2024-11-13 to 2024-11-16
    Flight from BCN to POR at 2024-11-16 17:00 to 19:10
    """
  end

  test "two trips.txt" do
    assert capture_io(fn ->
      assert FCM.print_trips_from_file("test/inputs/two_trips.txt") == :ok
    end) =~ """
    TRIP to TER
    Flight from POR to TER at 2024-10-12 12:00 to 15:15

    TRIP to BCN
    Flight from POR to BCN at 2024-11-09 09:00 to 11:20
    """
  end
end
