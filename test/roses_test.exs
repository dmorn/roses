defmodule RosesTest do
  use ExUnit.Case
  doctest Roses

  test "greets the world" do
    assert Roses.hello() == :world
  end
end
