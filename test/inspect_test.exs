defmodule InspectTest do
  use ExUnit.Case
  alias Sgf.Node

  test "turn a simple node into the correct string" do
    test_node = %Node{ ident_props: %{B: ["pd"]}}
    assert inspect(test_node) ==  ";B[pd]"
  end

  test "turn a node with multiple props into a string" do
    test_node = %Node{
      ident_props: %{AB: ["pd", "af"]}
    }
    assert inspect(test_node) == ";AB[pd][af]"
  end

  test "turn a node with multiple idents into a string" do
    test_node = %Node{
      ident_props: %{B: ["pd"], N: ["Moves, comments, annotations"]}
    }
    assert inspect(test_node) == ";B[pd]N[Moves, comments, annotations]"
  end
end
