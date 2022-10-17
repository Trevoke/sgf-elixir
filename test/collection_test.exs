defmodule ExSgf.CollectionTest do
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

  describe "collection" do

    test "ignores whitespace in collection parsing" do
      sgf = "\n (;C[g1root](;C[g1b1c1])(;C[g1b2c1];C[g1b2c2])) \n (;C[g2root];C[g2b1c1]) \n "

      colroot = ExSgf.Node.new(%{collection_root: true})

      g1root = ExSgf.Node.new(%{"C" => ["g1root"]})
      g1b1c1 = ExSgf.Node.new(%{"C" => ["g1b1c1"]})
      g1b2c1 = ExSgf.Node.new(%{"C" => ["g1b2c1"]})
      g1b2c2 = ExSgf.Node.new(%{"C" => ["g1b2c2"]})
      g2root = ExSgf.Node.new(%{"C" => ["g2root"]})
      g2b1c1 = ExSgf.Node.new(%{"C" => ["g2b1c1"]})

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

      {:ok, zipper} = ExSgf.from_string(sgf)
      actual = zipper_to_tree(zipper)

      #IO.inspect actual
#      IO.inspect RT.to_list(actual)
      #      IO.puts "---------------------------"
#      IO.inspect actual
      IO.inspect(RoseTree.paths(actual))
      gametree_count = Enum.count(actual.children)
      assert gametree_count == 2
      assert expected == actual
    end

    test "holds multiple gametrees" do
      sgf = "(;KM[6.5])(;KM[0.5])"
      {:ok, zipper} = ExSgf.from_string(sgf)
      actual = zipper_to_tree(zipper)
      gametree_count = Enum.count(actual.children)
      assert gametree_count == 2
    end

    test "parses the example SGF from red bean website correctly" do
      {:ok, sgf} = File.read(Path.join([Path.dirname(__ENV__.file), "data", "ff4_ex.sgf"]))
      {:ok, zipper} = ExSgf.from_string(sgf)

      actual = zipper_to_tree(zipper)
      gametree_count = Enum.count(actual.children)
      assert gametree_count == 2
    end
  end
end
