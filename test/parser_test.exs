defmodule ExSgf.ParserTest do
  use ExUnit.Case, async: true

  alias ExSgf.Parser

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
    test "tracks a single branch effectively" do
      sgf = "(;KM[6.5];AB[dd][cc])"
      child = RoseTree.new(%{"AB" => ["cc", "dd"]})
      expected = RoseTree.new(%{"KM" => ["6.5"]}) |> RoseTree.add_child(child)
      {zipper, ""} = Parser.parse_gametree(sgf, %{open_branches: 0})
      actual = zipper_to_tree(zipper)
      assert expected == actual
    end

    test "tracks sub-branches" do
      sgf = "(;KM[6.5](;AB[dd][cc])(;AW[ff][gg]))"
      root = RoseTree.new(%{"KM" => ["6.5"]})
      add_black = RoseTree.new(%{"AB" => ["cc", "dd"]})
      add_white = RoseTree.new(%{"AW" => ["gg", "ff"]})

      expected =
        root
        |> RoseTree.Zipper.from_tree()
        |> RoseTree.Zipper.insert_last_child(add_black)
        |> elem(1)
        |> RoseTree.Zipper.ascend()
        |> elem(1)
        |> RoseTree.Zipper.insert_last_child(add_white)
        |> elem(1)
        |> RoseTree.Zipper.to_root()
        |> RoseTree.Zipper.to_tree()

      {zipper, ""} = Parser.parse_gametree(sgf, %{open_branches: 0})
      actual = zipper_to_tree(zipper)
      assert expected == actual
    end
  end

  describe "collections" do
  end
end
