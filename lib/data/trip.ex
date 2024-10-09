defmodule FCM.Data.Trip do
  alias FCM.Data.Transport
  alias FCM.Data.Hotel

  @enforce_keys [:segments]
  defstruct [:segments]

  @type t :: %__MODULE__{
          segments: [Transport.t() | Hotel.t()]
        }

  @flight_change_hours_default 24

  @doc """
  Create a new Trip from reservations.
  Reservations are expected to be from one trip and sorted by time.
  """
  @spec new([Transport.t() | Hotel.t()]) :: t()
  def new(segments) do
    %__MODULE__{segments: segments}
  end

  @doc """
  Get IATA code of trip start.
  """
  @spec iata_from(t()) :: String.t() | nil
  def iata_from(%__MODULE__{segments: []}), do: nil
  def iata_from(%__MODULE__{segments: [%Transport{iata_from: iata_from} | _]}), do: iata_from

  @doc """
  Get IATA code of trip final destination.
  """
  @spec iata_final(t()) :: String.t() | nil
  def iata_final(%__MODULE__{segments: []}), do: nil

  def iata_final(%__MODULE__{segments: segments}) do
    segments
    |> Enum.filter(&match?(%Transport{}, &1))
    |> Enum.at(-1)
    |> then(fn %Transport{iata_to: iata_to} -> iata_to end)
  end

  @doc """
  Get IATA codes of places where user stays (no transport changes).
  """
  @spec iatas_staying(t()) :: [String.t()]
  def iatas_staying(%__MODULE__{segments: []}), do: []

  def iatas_staying(%__MODULE__{segments: segments} = trip) do
    iata_from = iata_from(trip)

    [_ | second_elements] = segments

    Enum.zip(segments, second_elements ++ [nil])
    |> Enum.map(fn
      {%Transport{}, %Hotel{iata: iata}} ->
        iata

      {%Transport{iata_to: iata, date_time_arrival: arrive_at},
       %Transport{date_time_departure: depart_at}} ->
        change_hours = NaiveDateTime.diff(depart_at, arrive_at, :hour)

        flight_change_hours =
          Application.get_env(:fcm, :flight_change_hours, @flight_change_hours_default)

        if change_hours >= flight_change_hours do
          iata
        else
          nil
        end

      {%Transport{iata_to: iata}, nil} ->
        if iata == iata_from do
          nil
        else
          iata
        end

      {_, _} ->
        nil
    end)
    |> Enum.reject(&is_nil/1)
  end
end
