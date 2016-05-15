defmodule NodeTest do
  use ExUnit.Case
  alias Sgf.Node

  test "create a simple node" do
    test_string = "B[pd]"
    actual = Sgf.Node.parse_node(test_string)
    assert %Node{ ident_props: %{B: ["pd"]}} == actual
  end

  test "create a complex node" do
    actual = Sgf.Node.parse_node "B[pd]N[Moves, comments, annotations]"
    assert %Node{
      ident_props: %{B: ["pd"], N: ["Moves, comments, annotations"]}
    } == actual
  end

  test "create a node with multiple props for a single ident" do
    actual = Sgf.Node.parse_node "AB[pd][af]"
    assert %Node{
      ident_props: %{AB: ["pd", "af"]}
    } == actual
  end

end
