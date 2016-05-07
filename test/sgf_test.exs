defmodule SgfTest do
  use ExUnit.Case
  alias Sgf.Node
  alias Sgf.Branch

  test "create a simple node" do
    actual = Sgf.Parser.parse_node("B[pd]")
    assert %Node{ ident_props: %{B: ["pd"]}} == actual
  end

  test "create a complex node" do
    actual = Sgf.Parser.parse_node "B[pd]N[Moves, comments, annotations]"
    assert %Node{
      ident_props: %{B: ["pd"], N: ["Moves, comments, annotations"]}
    } == actual
  end

  test "create a node with multiple props for a single ident" do
    actual = Sgf.Parser.parse_node "AB[pd][af]"
    assert %Node{
      ident_props: %{AB: ["pd" | "af"]}
    } == actual
  end

  test "create a branch with a single node" do
    actual = Sgf.Parser.parse ";B[pd]"
    assert %Branch{ node_branches: [%Node{ ident_props: %{B: ["pd"]}}]} == actual
  end

  test "create a branch with two nodes" do
    actual = Sgf.Parser.parse ";B[pd];W[hg]"
    assert %Branch{ node_branches: [
        %Node{ ident_props: %{B: ["pd"]}},
        %Node{ ident_props: %{W: ["hg"]}},
      ]} == actual
  end

  test "create a branch with a variation" do
    branch = ";B[pd](;W[dd])(;W[de])"
    actual = Sgf.Parser.parse(branch)
    expected = %Branch{ node_branches: [
        %Node{ ident_props: %{B: ["pd"]}},
        [
          %Branch{ node_branches: [ %Node{ ident_props: %{W: ["dd"]}} ] },
          %Branch{ node_branches: [ %Node{ ident_props: %{W: ["de"]}} ] }
        ]
      ]
    }
    assert expected == actual
  end
end
