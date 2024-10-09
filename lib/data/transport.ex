defmodule FCM.Data.Transport do

  alias FCM.Data.DateTimeUtil

  @enforce_keys [:kind, :iata_from, :iata_to, :date_time_departure, :date_time_arrival]
  defstruct [:kind, :iata_from, :iata_to, :date_time_departure, :date_time_arrival]

  @type t :: %__MODULE__{
    kind: :flight | :train,
    iata_from: String.t(),
    iata_to: String.t(),
    date_time_departure: NaiveDateTime.t(),
    date_time_arrival: NaiveDateTime.t()
  }

  @pattern ~r/(?<kind>[a-zA-Z]+)\s+(?<iata_from>[a-zA-Z]+)\s+(?<date_from>[\d-]+\s+[\d:]+)\s+->\s+(?<iata_to>[a-zA-Z]+)\s+(?<date_to>[\d:]+)/

  @doc """
  Parse Transport reservation from text.

  ##Examples

      iex> Transport.parse("Flight NRT 2020-01-01 12:00 -> HND 13:00")
      {:ok, %Transport{kind: :flight, iata_from: "NRT", iata_to: "HND", date_time_departure: ~N[2020-01-01 12:00:00], date_time_arrival: ~N[2020-01-01 13:00:00]}}
  """
  @spec parse(String.t()) :: {:ok, t()} | {:error, String.t()}
  def parse(text) do
    with {:format, %{
            "kind" => kind,
            "iata_from" => iata_from,
            "date_from" => date_from,
            "iata_to" => iata_to,
            "date_to" => date_to
          }} <- {:format, Regex.named_captures(@pattern, text)},
         {:kind, {:ok, kind_atom}} <-
          {:kind, parse_kind(kind)},
         {:iata_from, 3, ^iata_from, _} <-
          {:iata_from, String.length(iata_from), String.upcase(iata_from), iata_from},
         {:iata_to, 3, ^iata_to, _} <-
          {:iata_to, String.length(iata_to), String.upcase(iata_to), iata_to},
         {:date_from, {:ok, date_time_departure}, _} <-
          {:date_from, DateTimeUtil.parse_date_time(date_from), date_from},
         {:date_to, {:ok, time_arrival}, _} <-
          {:date_to, DateTimeUtil.parse_time(date_to), date_to} do
      {:ok, date_time_arrival} =
        NaiveDateTime.to_date(date_time_departure)
        |> NaiveDateTime.new(time_arrival)
      {
        :ok,
        %__MODULE__{
          kind: kind_atom,
          iata_from: iata_from,
          iata_to: iata_to,
          date_time_departure: date_time_departure,
          date_time_arrival: date_time_arrival
        }
      }
    else
      {:format, _} ->
        {:error, "Invalid format: #{text}"}

      {:kind, {:error, error}} ->
        {:error, "Invalid kind: #{error}"}

      {:iata_from, _, _, iata_from} ->
        {:error, "Invalid IATA from code: #{iata_from}"}

      {:iata_to, _, _, iata_to} ->
        {:error, "Invalid IATA to code: #{iata_to}"}

      {:date_from, {:error, reason}, date_from} ->
        {:error, "Invalid from date: #{date_from} (#{reason})"}

      {:date_to, {:error, reason}, date_to} ->
        {:error, "Invalid to date: #{date_to} (#{reason})"}
    end
  end

  defp parse_kind(kind) do
    String.trim(kind) |> String.downcase() |> kind_to_atom()
  end

  defp kind_to_atom("flight"), do: {:ok, :flight}
  defp kind_to_atom("train"), do: {:ok, :train}
  defp kind_to_atom(kind), do: {:error, kind}
end
