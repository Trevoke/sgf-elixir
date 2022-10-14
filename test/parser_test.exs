defmodule ExSgf.ParserTest do
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

  describe "sequences" do
    test "has two nodes one after the other" do
      chunk = ";;"
      root = ExSgf.Node.new
      root_zipper = root |> Z.from_tree()
      child = ExSgf.Node.new
      parent = ExSgf.Node.new
      expected =
        root_zipper
        |> Z.insert_last_child(parent)
        |> elem(1)
        |> Z.insert_last_child(child)
        |> elem(1)
        |> Z.to_root()
        |> Z.to_tree()
      {"", zipper} = ExSgf.Parser.Sequence.parse(chunk, %A{current_node: root_zipper})
      actual = zipper_to_tree(zipper.current_node)
      assert expected == actual
    end
  end

  describe "gametrees / branches" do
    test "tracks a single branch effectively" do
      sgf = "(;KM[6.5];AB[dd][cc])"
      root = ExSgf.Node.new()
      root_zipper = Z.from_tree(root)
      parent = ExSgf.Node.new(%{"KM" => ["6.5"]})
      child = ExSgf.Node.new(%{"AB" => ["cc", "dd"]})

      expected =
        root_zipper
        |> Z.insert_last_child(parent)
        |> Z.lift(&Z.insert_last_child(&1, child))
        |> Z.lift(&Z.to_root/1)
        |> Z.to_tree()

      {"", acc} = P.Gametree.parse(sgf, %A{current_node: root_zipper})
      actual = zipper_to_tree(acc.current_node)
      assert expected == actual
    end

    test "tracks sub-branches" do
      sgf = "(;KM[6.5](;AB[dd][cc])(;AW[ff][gg]))"
      root = ExSgf.Node.new()
      game_root = ExSgf.Node.new(%{"KM" => ["6.5"]})
      add_black = ExSgf.Node.new(%{"AB" => ["cc", "dd"]})
      add_white = ExSgf.Node.new(%{"AW" => ["gg", "ff"]})

      root_zipper = Z.from_tree(root)

      expected =
        root_zipper
        |> Z.insert_last_child(game_root)
        |> Z.lift(&Z.insert_last_child(&1, add_black))
        |> Z.lift(&Z.ascend/1)
        |> Z.lift(&Z.insert_last_child(&1, add_white))
        |> Z.lift(&Z.to_root/1)
        |> Z.to_tree()

      {"", acc} = P.Gametree.parse(sgf, %A{current_node: root_zipper})
      IO.inspect acc
      actual = zipper_to_tree(acc.current_node)
      IO.inspect actual
      assert expected == actual
    end

    test "closes two branches in a row" do
      sgf = ""
    end
  end

  describe "whitespace" do
    test "ignores whitespace when parsing" do
      sgf =
        "\n(\n  ;PB[Kumagaya Honseki]\n  BR[1p]\n  PW[Honinbo Dosaku]\n  KM[0]\n  RE[B+1]\n  DT[1697-09-24]\n  JD[Genroku 10-8-10]\n  ;B[cp]\n  ;W[pq]\n)\n"

      root = ExSgf.Node.new
      root_zipper = Z.from_tree(root)
      game_root = %{
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
        root_zipper
        |> Z.insert_last_child(game_root)
        |> Z.lift(&Z.insert_last_child(&1, move1))
        |> Z.lift(&Z.insert_last_child(&1, move2))
        |> Z.lift(&Z.to_root/1)
        |> Z.to_tree

      {"", zipper} = P.Gametree.parse(sgf, %A{current_node: root_zipper})
      actual = zipper_to_tree(zipper.current_node)
      assert expected == actual
    end
  end

  describe "collection" do

    test "ignores whitespace in collection parsing" do
      sgf = "(;C[g1root](;C[g1b1c1])(;C[g1b2c1];C[g1b2c2])) \n (;C[g2root];C[g2b1c1)"

      colroot = ExSgf.Node.new(%{collection_root: true})

      g1root = ExSgf.Node.new(%{"C" => ["g1root"]})
      g1b1c1 = ExSgf.Node.new(%{"C" => ["g1b1c1"]})
      g1b2c1 = ExSgf.Node.new(%{"C" => ["g1b2c1"]})
      g1b2c2 = ExSgf.Node.new(%{"C" => ["g1b2c2"]})
      g2root = ExSgf.Node.new(%{"C" => ["g2root"]})
      g2b1c1 = ExSgf.Node.new(%{"C" => ["g2b1c2"]})

      g1 =
        g1root
        |> Z.from_tree()
        |> Z.insert_last_child(g1b1c1)
        |> Z.lift(&Z.ascend/1)
        |> Z.lift(&Z.insert_last_child(&1, g1b2c1))
        |> Z.lift(&Z.insert_last_child(&1, g1b2c2))
        |> Z.lift(&Z.to_root/1)
        |> Z.to_tree
      g2 =
        g2root
        |> Z.from_tree()
        |> Z.insert_last_child(g2b1c1)
        |> Z.lift(&Z.to_root/1)
        |> Z.to_tree
      expected =
        colroot
        |> Z.from_tree()
        |> Z.insert_last_child(g1)
        |> Z.lift(&Z.ascend/1)
        |> Z.lift(&Z.insert_last_child(&1, g2))
        |> Z.lift(&Z.to_root/1)
        |> Z.to_tree

      #IO.inspect RoseTree.to_list(expected)
      {:ok, zipper} = ExSgf.from_string(sgf)
      actual = zipper_to_tree(zipper)

      IO.inspect actual
#      IO.puts "---------------------------"
#      IO.inspect actual
#      IO.inspect(RoseTree.paths(actual))
      gametree_count = Enum.count(actual.children)
      assert gametree_count == 2
    end

    test "holds multiple gametrees" do
      {:ok, sgf} = File.read(Path.join([Path.dirname(__ENV__.file), "data", "ff4_ex.sgf"]))
      {:ok, zipper} = ExSgf.from_string(sgf)

      actual = zipper_to_tree(zipper)
      #IO.inspect RoseTree.to_list(actual)
      gametree_count = Enum.count(actual.children)
      assert gametree_count == 2
    end
  end
end
