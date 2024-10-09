defmodule FCM.Data.BasedTest do
  use ExUnit.Case, async: true

  alias FCM.Data.Based

  doctest Based

  describe "parse" do
    test "POR" do
      assert {:ok, %Based{iata: "POR"}} == Based.parse("POR")
    end

    test "POR with whitespace" do
      assert {:ok, %Based{iata: "POR"}} == Based.parse(" POR ")
    end

    test "por" do
      {:error, msg} = Based.parse("por")
      assert msg =~ "Invalid IATA code: por"
    end

    test "PORTO" do
      {:error, msg} = Based.parse("PORTO")
      assert msg =~ "Invalid IATA code: PORTO"
    end
  end
end
