defmodule FCM.Data.Based do

  @enforce_keys [:iata]
  defstruct [:iata]

  @type t :: %__MODULE__{
    iata: String.t()
  }

  @doc """
  Parse Based from text.

  ## Examples

      iex> Based.parse("NRT")
      {:ok, %Based{iata: "NRT"}}
  """
  @spec parse(String.t()) :: {:ok, t()} | {:error, String.t()}
  def parse(text) do
    iata = String.trim(text)

    case {String.length(iata), String.upcase(iata)} do
      {3, ^iata} -> {:ok, %__MODULE__{iata: iata}}
      {_, _} -> {:error, "Invalid IATA code: #{iata}"}
    end
  end

end
