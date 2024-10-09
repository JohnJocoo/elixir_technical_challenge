defmodule FCM.Data.DateTimeUtil do
  @doc """
  Parse NaiveDateTime from arbiterary text.

  ## Examples

      iex> DateTimeUtil.parse_date_time("2020-01-01 12:00")
      {:ok, ~N[2020-01-01 12:00:00]}
  """
  @spec parse_date_time(binary()) :: {:ok, NaiveDateTime.t()} | {:error, any()}
  def parse_date_time(text) do
    DateTimeParser.parse_datetime(text)
  end

  @doc """
  Parse Date from arbiterary text.

  ## Examples

      iex> DateTimeUtil.parse_date("2020-01-01")
      {:ok, ~D[2020-01-01]}
  """
  @spec parse_date(binary()) :: {:ok, Date.t()} | {:error, any()}
  def parse_date(text) do
    DateTimeParser.parse_date(text)
  end

  @doc """
  Parse Time from arbiterary text.

  ## Examples

      iex> DateTimeUtil.parse_time("12:00")
      {:ok, ~T[12:00:00]}
  """
  @spec parse_time(binary()) :: {:ok, Time.t()} | {:error, any()}
  def parse_time(text) do
    DateTimeParser.parse_time(text)
  end
end
