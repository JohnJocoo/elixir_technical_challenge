defmodule FCMTest do
  use ExUnit.Case
  doctest FCM

  test "greets the world" do
    assert FCM.hello() == :world
  end
end
