defmodule ExSgf.GametreeTest do
  use ExUnit.Case, async: true

  alias ExSgf.Parser, as: P
  alias ExSgf.Accumulator, as: A

  alias RoseTree.Zipper, as: Z

  doctest ExSgf.Parser

  def zipper_to_tree(zipper) do
    zipper
    |> Z.to_root()
    |> Z.to_tree()
  end

  describe "parser" do
    test "stops when it finishes parsing a gametree" do
      sgf = "\n (;C[g1root](;C[g1b1c1])(;C[g1b2c1];C[g1b2c2])) \n (;C[g2root];C[g2b1c1]) \n "

      colroot = ExSgf.Node.new(%{collection_root: true})
      root_zipper = Z.from_tree(colroot)

      g1root = ExSgf.Node.new(%{"C" => "g1root"})
      g1b1c1 = ExSgf.Node.new(%{"C" => "g1b1c1"})
      g1b2c1 = ExSgf.Node.new(%{"C" => "g1b2c1"})
      g1b2c2 = ExSgf.Node.new(%{"C" => "g1b2c2"})

      g1 =
        g1root
        |> Z.from_tree()
        |> Z.insert_last_child(g1b1c1)
        |> Z.lift(&Z.ascend/1)
        |> Z.lift(&Z.insert_last_child(&1, g1b2c1))
        |> Z.lift(&Z.insert_last_child(&1, g1b2c2))
        |> Z.lift(&Z.to_root/1)
        |> Z.to_tree()

      expected =
        root_zipper
        |> Z.insert_last_child(g1)
        |> Z.lift(&Z.to_root/1)
        |> Z.to_tree()

      {" \n (;C[g2root];C[g2b1c1]) \n ", acc} =
        P.Gametree.parse(sgf, %A{current_node: root_zipper, gametree_status: :open})

      actual = zipper_to_tree(acc.current_node)
      assert expected == actual
    end
  end

  describe "whitespace" do
    test "ignores whitespace when parsing" do
      sgf =
        "\n(\n  ;PB[Kumagaya Honseki]\n  BR[1p]\n  PW[Honinbo Dosaku]\n  KM[0]\n  RE[B+1]\n  DT[1697-09-24]\n  JD[Genroku 10-8-10]\n  ;B[cp]\n  ;W[pq]\n)\n"

      root = ExSgf.Node.new()
      root_zipper = Z.from_tree(root)

      game_root =
        %{
          "BR" => "1p",
          "DT" => "1697-09-24",
          "JD" => "Genroku 10-8-10",
          "KM" => "0",
          "PB" => "Kumagaya Honseki",
          "PW" => "Honinbo Dosaku",
          "RE" => "B+1"
        }
        |> RoseTree.new()

      move1 = %{"B" => "cp"} |> RoseTree.new()
      move2 = %{"W" => "pq"} |> RoseTree.new()

      expected =
        root_zipper
        |> Z.insert_last_child(game_root)
        |> Z.lift(&Z.insert_last_child(&1, move1))
        |> Z.lift(&Z.insert_last_child(&1, move2))
        |> Z.lift(&Z.to_root/1)
        |> Z.to_tree()

      {"\n", zipper} =
        P.Gametree.parse(sgf, %A{current_node: root_zipper, gametree_status: :open})

      actual = zipper_to_tree(zipper.current_node)
      assert expected == actual
    end
  end

  describe "gametrees / branches" do
    test "tracks a single branch effectively" do
      sgf = "(;KM[6.5];AB[dd][cc])"
      root = ExSgf.Node.new()
      root_zipper = Z.from_tree(root)
      parent = ExSgf.Node.new(%{"KM" => "6.5"})
      child = ExSgf.Node.new(%{"AB" => ["cc", "dd"]})

      expected =
        root_zipper
        |> Z.insert_last_child(parent)
        |> Z.lift(&Z.insert_last_child(&1, child))
        |> Z.lift(&Z.to_root/1)
        |> Z.to_tree()

      {"", acc} = P.Gametree.parse(sgf, %A{current_node: root_zipper, gametree_status: :open})
      actual = zipper_to_tree(acc.current_node)
      assert expected == actual
    end

    test "tracks sub-branches" do
      sgf = "(;KM[6.5](;AB[dd][cc])(;AW[ff][gg]))"
      root = ExSgf.Node.new()
      game_root = ExSgf.Node.new(%{"KM" => "6.5"})
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

      {"", acc} = P.Gametree.parse(sgf, %A{current_node: root_zipper, gametree_status: :open})
      actual = zipper_to_tree(acc.current_node)
      assert expected == actual
    end
  end
end
