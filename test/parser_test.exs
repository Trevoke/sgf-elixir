defmodule ExSgf.ParserTest do
  use ExUnit.Case, async: true

  alias ExSgf.Parser
  alias ExSgf.Accumulator, as: A

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
      actual = Parser.parse_property_identity(chunk, %A{})
      assert expected == actual
    end
  end

  describe "property values" do
    test "continues until there is a closing bracket" do
      chunk = "[foobarbaz]"
      expected = {["foobarbaz"], ""}
      actual = Parser.parse_property_value(chunk, %A{property_value: [], value_status: :closed})
      assert expected == actual
    end

    test "continues while there is an opening bracket after a closing bracket" do
      chunk = "[foobarbaz][foobarqux]"
      expected = {["foobarbaz", "foobarqux"], ""}
      actual = Parser.parse_property_value(chunk, %A{property_value: [], value_status: :closed})
      assert expected == actual
    end

    test "reads multiple values on multiple lines" do
      chunk = "[foobarbaz]\n[foobarqux]"
      expected = {["foobarbaz", "foobarqux"], ""}
      actual = Parser.parse_property_value(chunk, %A{property_value: [], value_status: :closed})
      assert expected == actual
    end

    test "treat an escaped closing bracket as part of the value" do
      chunk = "[foobar\\]baz]"
      expected = {["foobar\\]baz"], ""}
      actual = Parser.parse_property_value(chunk, %A{property_value: [], value_status: :closed})
      assert expected == actual
    end
  end

  describe "nodes" do
    test "can be empty" do
      chunk = ";;"
      expected = RoseTree.new(%{})
      {";", actual} = Parser.parse_node(chunk, %A{})
      assert expected == actual
    end

    test "has multiple properties" do
      chunk = ";KM[6.5]AB[dd][cc]"
      expected = RoseTree.new(%{"KM" => ["6.5"], "AB" => ["dd", "cc"]})
      {"", actual} = Parser.parse_node(chunk, %A{})
      assert expected == actual
    end
  end

  describe "sequences" do
    test "has two nodes one after the other" do
      chunk = ";;"
      child = RoseTree.new(%{})
      parent = RoseTree.new(%{}) |> RoseTree.add_child(child)
      expected = parent
      {"", zipper} = Parser.parse_sequence(chunk, %{})
      actual = zipper_to_tree(zipper.current_node)
      assert expected == actual
    end
  end

  describe "gametrees / branches" do
    test "tracks a single branch effectively" do
      sgf = "(;KM[6.5];AB[dd][cc])"
      child = RoseTree.new(%{"AB" => ["cc", "dd"]})
      expected = RoseTree.new(%{"KM" => ["6.5"]}) |> RoseTree.add_child(child)
      {"", zipper} = Parser.parse_gametree(sgf, %A{open_branches: 0})
      actual = zipper_to_tree(zipper.current_node)
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

      {"", zipper} = Parser.parse_gametree(sgf, %A{open_branches: 0})
      actual = zipper_to_tree(zipper.current_node)
      assert expected == actual
    end
  end

  describe "whitespace" do
    test "ignores whitespace when parsing" do
      sgf =
        "\n(\n  ;PB[Kumagaya Honseki]\n  BR[1p]\n  PW[Honinbo Dosaku]\n  KM[0]\n  RE[B+1]\n  DT[1697-09-24]\n  JD[Genroku 10-8-10]\n  ;B[cp]\n  ;W[pq]\n)\n"

      root = %{
        "BR" => ["1p"],
        "DT" => ["1697-09-24"],
        "JD" => ["Genroku 10-8-10"],
        "KM" => ["0"],
        "PB" => ["Kumagaya Honseki"],
        "PW" => ["Honinbo Dosaku"],
        "RE" => ["B+1"]
      } |> RoseTree.new
      move1 = %{"B" => ["cp"]} |> RoseTree.new
      move2 = %{"W" => ["pq"]} |> RoseTree.new
      expected =
        root
        |> RoseTree.Zipper.from_tree
        |> RoseTree.Zipper.insert_last_child(move1)
        |> elem(1)
        |> RoseTree.Zipper.insert_last_child(move2)
        |> elem(1)
        |> RoseTree.Zipper.to_root
        |> RoseTree.Zipper.to_tree

      {"", zipper} = Parser.parse_gametree(sgf, %A{open_branches: 0})
      actual = zipper_to_tree(zipper.current_node)
      assert expected == actual
    end
  end

  describe "collection" do

    test "xx" do
      sgf = "(;C[game1root];C[child1](;C[branch1child1];C[branch1child2])) \n (;C[game2root];C[game2child1)"
      {:ok, zipper} = ExSgf.from_string(sgf)

      actual = zipper_to_tree(zipper)
      IO.puts "---------------------------"
      IO.inspect actual
      IO.inspect(RoseTree.paths(actual))
      gametree_count = Enum.count(actual.children)
      assert gametree_count == 2
    end

    test "holds multiple gametrees" do
      {:ok, sgf} = File.read(Path.join([Path.dirname(__ENV__.file), "data", "ff4_ex.sgf"]))
      {:ok, zipper} = ExSgf.from_string(sgf)

      actual = zipper_to_tree(zipper)

      gametree_count = Enum.count(actual.children)
      assert gametree_count == 2
    end
  end
end
