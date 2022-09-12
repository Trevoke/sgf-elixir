defmodule ExSgfTest do
  use ExUnit.Case

  alias ExSgf.{Collection, GameTree}

  doctest ExSgf

  test "parses an empty tree" do
    tree = "(;)"
    actual = ExSgf.from_string(tree)
    expected = %Collection{
      gametrees: [
        %GameTree{
          nodes: [
            %{}
          ]}
      ]}
    assert expected == actual
  end

  test "puts properties on a node" do
    tree = "(;KM[6.5])"
    actual = ExSgf.from_string(tree)
    expected = %Collection{
      gametrees: [
        %GameTree{
          nodes: [
            %{"KM" => "6.5"}
        ]}
      ]}
    assert expected == actual
  end
end
