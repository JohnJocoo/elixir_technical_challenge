defmodule FCM do
  alias FCM.Data
  alias FCM.Data.{Based, Hotel, Transport, Trip}

  @flight_change_hours_default 24

  @doc """
  Print trips from a file to stdout.
  """
  @spec print_trips_from_file(String.t()) :: :ok
  def print_trips_from_file(path) do
    {:ok, reservations} = read_reservations_from_file(path)
    trips = trips_from_reservations(reservations)

    Enum.each(trips, fn %Trip{segments: segments} = trip ->
      IO.puts("TRIP to #{Trip.iatas_staying(trip) |> Enum.join(", ")}")

      Enum.each(segments, fn
        %Transport{
          kind: kind,
          iata_from: iata_from,
          iata_to: iata_to,
          date_time_departure: date_time_departure,
          date_time_arrival: date_time_arrival
        } ->
          time_arrival = NaiveDateTime.to_time(date_time_arrival)

          IO.puts(
            "#{transport_kind_to_string(kind)} from #{iata_from} to #{iata_to} " <>
              "at #{date_time_to_string(date_time_departure)} " <>
              "to #{time_to_string(time_arrival)}"
          )

        %Hotel{
          iata: iata,
          date_first: date_first,
          date_last: date_last
        } ->
          IO.puts(
            "Hotel at #{iata} on " <>
              "#{date_to_string(date_first)} " <>
              "to #{date_to_string(date_last)}"
          )
      end)

      IO.puts("")
    end)
  end

  @doc """
  Create trips from reservations.
  """
  @spec trips_from_reservations(Data.t()) :: [Trip.t()]
  def trips_from_reservations(%Data{based: %Based{iata: iata_based}} = data) do
    hotels_by_iata = reservations_to_hotels_by_iata(data.reservations)

    {trips_start, transport_by_iata} =
      reservations_to_transport_by_iata(data.reservations)
      |> Map.pop(iata_based, [])

    Enum.reduce(trips_start, {[], hotels_by_iata, transport_by_iata}, fn initial_transports,
                                                                         {trips, hotels_by_iata,
                                                                          transport_by_iata} ->
      {trip, updated_hotels, updated_transports} =
        create_trip(initial_transports, hotels_by_iata, transport_by_iata)

      {[trip | trips], updated_hotels, updated_transports}
    end)
    |> elem(0)
    |> Enum.reverse()
  end

  @doc """
  Read reservations from a file.
  """
  @spec read_reservations_from_file(String.t()) :: {:ok, Data.t()} | {:error, String.t()}
  def read_reservations_from_file(path) do
    File.open!(path, [:read, :utf8], fn file ->
      IO.stream(file, :line)
      |> Data.parse()
    end)
  end

  defp reservations_to_hotels_by_iata(reservations) do
    reservations
    |> Enum.flat_map(fn segments ->
      Enum.filter(segments, &match?(%Hotel{}, &1))
    end)
    |> Enum.group_by(& &1.iata)
    |> Map.new(fn {iata, hotels} ->
      {iata, Enum.sort_by(hotels, & &1.date_first, Date)}
    end)
  end

  defp reservations_to_transport_by_iata(reservations) do
    reservations
    |> Enum.map(fn segments ->
      segments
      |> Enum.filter(&match?(%Transport{}, &1))
      |> Enum.sort_by(& &1.date_time_departure, NaiveDateTime)
    end)
    |> Enum.reject(&match?([], &1))
    |> Enum.group_by(fn [%Transport{iata_from: iata} | _] -> iata end)
    |> Map.new(fn {iata, transports} ->
      transports_sorted =
        Enum.sort_by(
          transports,
          fn [%Transport{date_time_departure: departure} | _] ->
            departure
          end,
          NaiveDateTime
        )

      {iata, transports_sorted}
    end)
  end

  defp create_trip(initial_transports, hotels_by_iata, transport_by_iata) do
    create_trip_impl(initial_transports, [], hotels_by_iata, transport_by_iata)
  end

  defp create_trip_impl([%Transport{} = step | transports], [], hotels_by_iata, transport_by_iata) do
    create_trip_impl(transports, [step], hotels_by_iata, transport_by_iata)
  end

  defp create_trip_impl(
         transports,
         [current_segment | _] = segments,
         hotels_by_iata,
         transport_by_iata
       ) do
    case try_transport(current_segment, transports) do
      {nil, updated_transports} ->
        create_trip_impl_by_iata(updated_transports, segments, hotels_by_iata, transport_by_iata)

      {%Transport{} = step, updated_transports} ->
        create_trip_impl(updated_transports, [step | segments], hotels_by_iata, transport_by_iata)
    end
  end

  defp create_trip_impl_by_iata(
         transports,
         [current_segment | _] = segments,
         hotels_by_iata,
         transport_by_iata
       ) do
    case pop_fitting_transports(current_segment, transport_by_iata) do
      {nil, updated_transport} ->
        create_trip_impl_hotel(transports, segments, hotels_by_iata, updated_transport)

      {[%Transport{} = step | other_transports], updated_transport} ->
        new_transports =
          (other_transports ++ transports)
          |> Enum.sort_by(& &1.date_time_departure, NaiveDateTime)

        create_trip_impl(new_transports, [step | segments], hotels_by_iata, updated_transport)
    end
  end

  defp create_trip_impl_hotel(
         transports,
         [current_segment | _] = segments,
         hotels_by_iata,
         transport_by_iata
       ) do
    case pop_fitting_hotel(current_segment, hotels_by_iata) do
      {nil, updated_hotels} ->
        create_trip_finish(transports, segments, updated_hotels, transport_by_iata)

      {%Hotel{} = step, updated_hotels} ->
        create_trip_impl(transports, [step | segments], updated_hotels, transport_by_iata)
    end
  end

  defp create_trip_finish([], segments, hotels_by_iata, transport_by_iata) do
    trip = Enum.reverse(segments) |> Trip.new()
    {trip, hotels_by_iata, transport_by_iata}
  end

  defp create_trip_finish(
         [%Transport{} = step | transports],
         segments,
         hotels_by_iata,
         transport_by_iata
       ) do
    create_trip_impl(transports, [step | segments], hotels_by_iata, transport_by_iata)
  end

  defp segment_fits_transport?(
         %Transport{iata_to: iata_at, date_time_arrival: arrived},
         %Transport{iata_from: iata_from, date_time_departure: departure}
       ) do
    flight_change_hours =
      Application.get_env(:fcm, :flight_change_hours, @flight_change_hours_default)

    iata_from == iata_at && NaiveDateTime.diff(departure, arrived, :hour) < flight_change_hours
  end

  defp segment_fits_transport?(
         %Hotel{iata: iata_at, date_last: date},
         %Transport{iata_from: iata_from, date_time_departure: departure}
       ) do
    departure_date = NaiveDateTime.to_date(departure)

    iata_from == iata_at && Date.compare(departure_date, date) == :eq
  end

  defp try_transport(_, []), do: {nil, []}

  defp try_transport(segment, [%Transport{} = new_transport | rest_transports] = transports) do
    if segment_fits_transport?(segment, new_transport) do
      {new_transport, rest_transports}
    else
      {nil, transports}
    end
  end

  defp pop_fitting_transports(current_segment, transport_by_iata) do
    iata_at =
      case current_segment do
        %Transport{iata_to: iata} -> iata
        %Hotel{iata: iata} -> iata
      end

    case Map.pop(transport_by_iata, iata_at) do
      {nil, _} ->
        {nil, transport_by_iata}

      {transports, updated_transports} ->
        Enum.split_with(transports, fn [%Transport{} = transport | _] ->
          segment_fits_transport?(current_segment, transport)
        end)
        |> then(fn
          {[], _} ->
            {nil, transport_by_iata}

          {[transports | rest_transports], other_transports} ->
            new_transports =
              (rest_transports ++ other_transports)
              |> Enum.sort_by(
                fn [%Transport{date_time_departure: departure} | _] ->
                  departure
                end,
                NaiveDateTime
              )

            {transports, Map.put(updated_transports, iata_at, new_transports)}
        end)
    end
  end

  defp pop_fitting_hotel(current_segment, hotels_by_iata) do
    {iata_at, date} =
      case current_segment do
        %Transport{iata_to: iata, date_time_arrival: date} ->
          {iata, NaiveDateTime.to_date(date)}

        %Hotel{iata: iata, date_last: date} ->
          {iata, date}
      end

    case Map.pop(hotels_by_iata, iata_at) do
      {nil, _} ->
        {nil, hotels_by_iata}

      {hotels, updated_hotels} ->
        Enum.split_with(hotels, fn %Hotel{iata: iata, date_first: date_first} ->
          iata == iata_at && Date.compare(date_first, date) == :eq
        end)
        |> then(fn
          {[], _} ->
            {nil, hotels_by_iata}

          {[%Hotel{} = hotel | rest_hotels], other_hotels} ->
            new_hotels =
              (rest_hotels ++ other_hotels)
              |> Enum.sort_by(& &1.date_first, Date)

            {hotel, Map.put(updated_hotels, iata_at, new_hotels)}
        end)
    end
  end

  defp transport_kind_to_string(:flight), do: "Flight"
  defp transport_kind_to_string(:train), do: "Train"

  defp date_time_to_string(date_time) do
    date = NaiveDateTime.to_date(date_time)
    time = NaiveDateTime.to_time(date_time)

    "#{date_to_string(date)} #{time_to_string(time)}"
  end

  defp date_to_string(date) do
    print_two_digits = fn value ->
      Integer.to_string(value)
      |> String.pad_leading(2, "0")
    end

    "#{date.year}-#{print_two_digits.(date.month)}-#{print_two_digits.(date.day)}"
  end

  defp time_to_string(time) do
    print_two_digits = fn value ->
      Integer.to_string(value)
      |> String.pad_leading(2, "0")
    end

    "#{print_two_digits.(time.hour)}:#{print_two_digits.(time.minute)}"
  end
end
