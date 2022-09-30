defmodule ExSgf.ParserTest do
  use ExUnit.Case, async: true

  alias ExSgf.{Collection, Node, Parser}

  doctest ExSgf.Parser

  def zipper_to_tree(zipper) do
    zipper
    |> RoseTree.Zipper.to_root
    |> RoseTree.Zipper.to_tree
  end

  describe "property identities" do
    test "continues until it finds an open bracket" do
      chunk = "AB["
      expected = {"AB", "["}
      actual = Parser.parse_property_identity(chunk, %{})
      assert expected == actual
    end
  end
  describe "property values" do
    test "continues until there is a closing bracket" do
      chunk = "[foobarbaz]"
      expected = {["foobarbaz"], ""}
      actual = Parser.parse_property_value(chunk, %{property_value: [], value_status: :closed})
      assert expected == actual
    end
    test "continues while there is an opening bracket after a closing bracket" do
      chunk = "[foobarbaz][foobarqux]"
      expected = {["foobarbaz", "foobarqux"], ""}
      actual = Parser.parse_property_value(chunk, %{property_value: [], value_status: :closed})
      assert expected == actual
    end

    test "treat an escaped closing bracket as part of the value" do
      chunk = "[foobar\\]baz]"
      expected = {["foobar\\]baz"], ""}
      actual = Parser.parse_property_value(chunk, %{property_value: [], value_status: :closed})
      assert expected == actual
    end
  end

  describe "nodes" do
    test "can be empty" do
      chunk = ";;"
      expected = RoseTree.new(%{})
      {actual, ";"} = Parser.parse_node(chunk, %{})
      assert expected == actual
    end
    test "has multiple properties" do
      chunk = ";KM[6.5]AB[dd][cc]"
      expected = RoseTree.new(%{"KM" => ["6.5"], "AB" => ["dd", "cc"]})
      {actual, ""} = Parser.parse_node(chunk, %{})
      assert expected == actual
    end
  end

  describe "sequences" do
    test "has two nodes one after the other" do
      chunk = ";;"
      child = RoseTree.new(%{})
      parent = RoseTree.new(%{}) |> RoseTree.add_child(child)
      expected = parent
      {zipper, ""} = Parser.parse_sequence(chunk, %{})
      actual = zipper_to_tree(zipper)
      assert expected == actual
    end
  end

  describe "gametrees / branches" do
  end

  describe "collections" do
  end

end
