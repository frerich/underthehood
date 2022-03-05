defmodule UnderthehoodTest do
  use ExUnit.Case
  doctest Underthehood

  test "greets the world" do
    assert Underthehood.hello() == :world
  end
end
