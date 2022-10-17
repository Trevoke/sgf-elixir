defmodule ExSgf.SequenceTest do
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

end
