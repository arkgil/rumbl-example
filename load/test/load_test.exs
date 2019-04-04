defmodule LoadTest do
  use ExUnit.Case
  doctest Load

  test "greets the world" do
    assert Load.hello() == :world
  end
end
