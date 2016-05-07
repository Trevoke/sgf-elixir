defmodule SgfTest do
  use ExUnit.Case
  alias Sgf.Node

  #  test "parses a branch with one node" do
  #    branch = "(;B[pd]N[Moves, comments, annotations];W[dp]GW[1])"
  #    tree = Sgf.Parser.parse branch
  #    expected = ["B[pd]N[Moves, comments, annotations]", "W[dp]GW[1]"]
  #    assert tree == expected
  #  end
  #
  #  test "creates a struct representation of the node" do
  #    node_string = "B[pd]N[Moves, comments, annotations]"
  #    struct = Sgf.Parser.nodify node_string
  #    expected = %{B: "pd", N: "Moves, comments, annotations"}
  #    assert struct == expected
  #  end

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

  # indent props needs to be able to handle mulitple props for a single identitiy
end
