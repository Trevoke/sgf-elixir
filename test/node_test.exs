defmodule ExSgf.NodeTest do
  use ExUnit.Case, async: true

  alias ExSgf.Parser, as: P
  alias ExSgf.Accumulator, as: A
  alias ExSgf.Node

  describe "nodes" do
    test "can be empty" do
      chunk = ";;"
      expected = Node.new(%{})
      {";", actual} = P.Node.parse(chunk, %A{})
      assert expected == actual
    end

    test "has multiple properties" do
      chunk = ";KM[6.5]AB[dd][cc]"
      expected = Node.new(%{"KM" => "6.5", "AB" => ["dd", "cc"]})
      {"", actual} = P.Node.parse(chunk, %A{})
      assert expected == actual
    end
  end
end
