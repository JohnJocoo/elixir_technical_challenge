defmodule FCM.Data.DateTimeUtilTest do
  use ExUnit.Case, async: true

  alias FCM.Data.DateTimeUtil

  doctest DateTimeUtil

  describe "parse_date_time" do
    test "2024-10-05 12:00" do
      assert {:ok, ~N[2024-10-05 12:00:00]} == DateTimeUtil.parse_date_time("2024-10-05 12:00")
    end

    test "2024-10-05 12:00:00" do
      assert {:ok, ~N[2024-10-05 12:00:00]} == DateTimeUtil.parse_date_time("2024-10-05 12:00:00")
    end

    test "2024-10-05 12:00:00.000" do
      assert {:ok, ~N[2024-10-05 12:00:00.000]} == DateTimeUtil.parse_date_time("2024-10-05 12:00:00.000")
    end

    test "5 October 2024 13:00" do
      assert {:ok, ~N[2024-10-05 13:00:00]} == DateTimeUtil.parse_date_time("5 October 2024 13:00")
    end

    test "Tomorrow 5pm" do
      {:error, _} = DateTimeUtil.parse_date_time("Tomorrow 5pm")
    end
  end

  describe "parse_date" do
    test "2024-10-05" do
      assert {:ok, ~D[2024-10-05]} == DateTimeUtil.parse_date("2024-10-05")
    end

    test "5 October 2024" do
      assert {:ok, ~D[2024-10-05]} == DateTimeUtil.parse_date("5 October 2024")
    end

    test "Tomorrow" do
      {:error, _} = DateTimeUtil.parse_date("Tomorrow")
    end
  end

  describe "parse_time" do
    test "12:00" do
      assert {:ok, ~T[12:00:00]} == DateTimeUtil.parse_time("12:00")
    end

    test "12:00:00" do
      assert {:ok, ~T[12:00:00]} == DateTimeUtil.parse_time("12:00:00")
    end

    test "12:00:00.000" do
      assert {:ok, ~T[12:00:00.000]} == DateTimeUtil.parse_time("12:00:00.000")
    end

    test "5pm" do
      {:error, _} = DateTimeUtil.parse_time("5pm")
    end
  end
end
