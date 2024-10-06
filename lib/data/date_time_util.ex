defmodule FCM.Data.DateTimeUtil do

  def parse_date_time(text) do
    DateTimeParser.parse_datetime(text)
  end

  def parse_date(text) do
    DateTimeParser.parse_date(text)
  end

  def parse_time(text) do
    DateTimeParser.parse_time(text)
  end
end
