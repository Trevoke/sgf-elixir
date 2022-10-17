defmodule ExSgf.NodeTest do
  use ExUnit.Case, async: true

  alias ExSgf.Parser, as: P
  alias ExSgf.Accumulator, as: A

  alias RoseTree, as: RT
  alias RoseTree.Zipper, as: Z

  doctest ExSgf.Parser

  def zipper_to_tree(zipper) do
    zipper
    |> RoseTree.Zipper.to_root()
    |> RoseTree.Zipper.to_tree()
  end

  describe "property identities" do
    test "continues until it finds an open bracket" do
      chunk = "AB["
      expected = {"AB", "["}
      actual = P.Node.parse_property_identity(chunk, %A{})
      assert expected == actual
    end
  end

  describe "property values" do
    test "continues until there is a closing bracket" do
      chunk = "[foobarbaz]"
      expected = {["foobarbaz"], ""}
      actual = P.Node.parse_property_value(chunk, %A{property_value: [], value_status: :closed})
      assert expected == actual
    end

    test "continues while there is an opening bracket after a closing bracket" do
      chunk = "[foobarbaz][foobarqux]"
      expected = {["foobarbaz", "foobarqux"], ""}
      actual = P.Node.parse_property_value(chunk, %A{property_value: [], value_status: :closed})
      assert expected == actual
    end

    test "reads multiple values on multiple lines" do
      chunk = "[foobarbaz]\n[foobarqux]"
      expected = {["foobarbaz", "foobarqux"], ""}
      actual = P.Node.parse_property_value(chunk, %A{property_value: [], value_status: :closed})
      assert expected == actual
    end

    test "treat an escaped closing bracket as part of the value" do
      chunk = "[foobar\\]baz]"
      expected = {["foobar\\]baz"], ""}
      actual = P.Node.parse_property_value(chunk, %A{property_value: [], value_status: :closed})
      assert expected == actual
    end
  end

  describe "nodes" do
    test "can be empty" do
      chunk = ";;"
      expected = RoseTree.new(%{})
      {";", actual} = P.Node.parse(chunk, %A{})
      assert expected == actual
    end

    test "has multiple properties" do
      chunk = ";KM[6.5]AB[dd][cc]"
      expected = RoseTree.new(%{"KM" => ["6.5"], "AB" => ["dd", "cc"]})
      {"", actual} = P.Node.parse(chunk, %A{})
      assert expected == actual
    end
  end

end
