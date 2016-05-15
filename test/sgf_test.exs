defmodule SgfTest do
  use ExUnit.Case
  alias Sgf.Branch
  alias Sgf.Node

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
