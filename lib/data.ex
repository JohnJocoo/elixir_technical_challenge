defmodule FCM.Data do

  alias FCM.Data.Based
  alias FCM.Data.Hotel
  alias FCM.Data.Transport

  defstruct [:based, :reservations]

  @type t :: %__MODULE__{}

  @pattern_based ~r/^BASED:\s+(.+)/
  @pattern_reservation ~r/^RESERVATION/
  @pattern_segment ~r/^SEGMENT:\s+([a-zA-Z]+)(.+)/

  @segment_module_map %{
    "hotel" => Hotel,
    "flight" => Transport,
    "train" => Transport
  }

  def parse(lines) do
    Enum.reduce_while(lines, %__MODULE__{reservations: []}, &parse_line/2)
    |> then(fn
      %__MODULE__{reservations: reservations} = data ->
        reversed_reservations =
          reservations
          |> Enum.map(&Enum.reverse/1)
          |> Enum.reverse()

        {:ok, %__MODULE__{data | reservations: reversed_reservations}}

      {:error, error} ->
        {:error, error}
    end)
  end

  defp parse_line(line, %__MODULE__{reservations: reservations} = data) do
    cond do
      String.trim(line) == "" ->
        {:cont, data}

      Regex.match?(@pattern_based, line) ->
        parse_based(line, data)

      Regex.match?(@pattern_reservation, line) ->
        {:cont, %__MODULE__{data | reservations: [[] | reservations]}}

      Regex.match?(@pattern_segment, line) ->
        parse_segment(line, data)

      true ->
        {:halt, {:error, "Invalid data in line: #{line}"}}
    end
  end

  defp parse_based(line, %__MODULE__{based: nil} = data) do
    [_, based_text] = Regex.run(@pattern_based, line)
    case Based.parse(based_text) do
      {:ok, based} -> {:cont, %__MODULE__{data | based: based}}
      {:error, error} -> {:halt, {:error, error}}
    end
  end

  defp parse_segment(line, %__MODULE__{reservations: [reservation | reservations]} = data) do
    [_, kind, segment_rest] = Regex.run(@pattern_segment, line)
    kind_normal = String.trim(kind) |> String.downcase()
    segment_text = "#{kind}#{segment_rest}"
    case Map.get(@segment_module_map, kind_normal) do
      nil ->
        {:halt, {:error, "Invalid segment kind: #{kind}"}}

      module ->
        case module.parse(segment_text) do
          {:ok, segment} ->
            {:cont, %__MODULE__{data | reservations: [[segment | reservation] | reservations]}}

          {:error, error} ->
            {:halt, {:error, error}}
        end
    end
  end
end
