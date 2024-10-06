defmodule FCM.Data.Trip do

  alias FCM.Data.Transport
  alias FCM.Data.Hotel

  defstruct [:segments]

  @type t :: %__MODULE__{}

  @flight_change_hours 24

  def new(segments) do
    %__MODULE__{segments: segments}
  end

  def iata_from(%__MODULE__{segments: []}), do: nil
  def iata_from(%__MODULE__{segments: [%Transport{iata_from: iata_from} | _]}), do: iata_from

  def iata_final(%__MODULE__{segments: []}), do: nil
  def iata_final(%__MODULE__{segments: segments}) do
    segments
    |> Enum.filter(&match?(%Transport{}, &1))
    |> Enum.at(-1)
    |> then(fn %Transport{iata_to: iata_to} -> iata_to end)
  end

  def iatas_staying(%__MODULE__{segments: []}), do: []
  def iatas_staying(%__MODULE__{segments: segments} = trip) do
    iata_from = iata_from(trip)

    [_ | second_elements] = segments
    Enum.zip(segments, second_elements ++ [nil])
    |> Enum.map(fn
      {%Transport{}, %Hotel{iata: iata}} ->
        iata

      {%Transport{iata_to: iata, date_time_arrival: arrive_at}, %Transport{date_time_departure: depart_at}} ->
        change_hours = NaiveDateTime.diff(depart_at, arrive_at, :hour)
        if change_hours >= @flight_change_hours do
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
