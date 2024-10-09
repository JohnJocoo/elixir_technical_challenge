defmodule FCM.Data.Hotel do
  alias FCM.Data.DateTimeUtil

  @enforce_keys [:iata, :date_first, :date_last]
  defstruct [:iata, :date_first, :date_last]

  @type t :: %__MODULE__{
          iata: String.t(),
          date_first: Date.t(),
          date_last: Date.t()
        }

  @pattern ~r/(?<iata>[a-zA-Z]+)\s+(?<from>[\d-]+)\s+->\s+(?<to>[\d-]+)/

  @doc """
  Parse Hotel reservation from text.

  ## Examples

      iex> Hotel.parse("NRT 2020-01-01 -> 2020-01-02")
      {:ok, %Hotel{iata: "NRT", date_first: ~D[2020-01-01], date_last: ~D[2020-01-02]}}
  """
  @spec parse(String.t()) :: {:ok, t()} | {:error, String.t()}
  def parse(text) do
    with {:format,
          %{
            "iata" => iata,
            "from" => from,
            "to" => to
          }} <- {:format, Regex.named_captures(@pattern, text)},
         {:from, {:ok, date_first}, _} <- {:from, DateTimeUtil.parse_date(from), from},
         {:to, {:ok, date_last}, _} <- {:to, DateTimeUtil.parse_date(to), to},
         {:iata, 3, ^iata, _} <- {:iata, String.length(iata), String.upcase(iata), iata} do
      {:ok, %__MODULE__{iata: iata, date_first: date_first, date_last: date_last}}
    else
      {:format, _} ->
        {:error, "Invalid format: #{text}"}

      {:from, {:error, reason}, from} ->
        {:error, "Invalid from date: #{from} (#{reason})"}

      {:to, {:error, reason}, to} ->
        {:error, "Invalid to date: #{to} (#{reason})"}

      {:iata, _, _, iata} ->
        {:error, "Invalid IATA code: #{iata}"}
    end
  end
end
