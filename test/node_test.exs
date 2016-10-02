defmodule NodeTest do
  use ExUnit.Case
  alias Sgf.Node

  test "create a simple node" do
    test_string = "B[pd]"
    actual = Sgf.Node.parse_node(test_string)
    assert ";#{test_string}" == inspect(actual)
  end

  test "create a complex node" do
    test_string =  "B[pd]N[Moves, comments, annotations]"
    actual = Sgf.Node.parse_node test_string
    assert ";#{test_string}" == inspect(actual)
  end

  test "create a node with multiple props for a single ident" do
    test_string = "AB[pd][af]"
    actual = Sgf.Node.parse_node test_string
    assert ";#{test_string}" == inspect(actual)
  end

  test "parses a comment" do
    test_string = "C[Oh hi\\] there]"
    actual = Sgf.Node.parse_node test_string
    assert ";#{test_string}" == inspect(actual)
  end

end
