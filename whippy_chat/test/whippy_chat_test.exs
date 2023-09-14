defmodule WhippyChatTest do
  use ExUnit.Case
  doctest WhippyChat

  test "greets the world" do
    assert WhippyChat.hello() == :world
  end
end
