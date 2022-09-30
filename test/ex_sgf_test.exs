defmodule ExSgfTest do
  use ExUnit.Case

#  alias ExSgf.{Collection, GameTree}

  #doctest ExSgf

  # test "parses a tree with one empty node" do
  #   sgf = "(;)"
  #   actual = ExSgf.from_string(sgf)
  #   expected = %Collection{
  #     gametrees: [
  #       %GameTree{
  #         nodes: [
  #           %{}
  #         ]}
  #     ]}
  #   assert expected == actual
  # end

  # test "puts properties on a node" do
  #   sgf = "(;KM[6.5])"
  #   actual = ExSgf.from_string(sgf)
  #   expected = %Collection{
  #     gametrees: [
  #       %GameTree{
  #         nodes: [
  #           %{"KM" => "6.5"}
  #         ]}
  #     ]}
  #   assert expected == actual
  # end

  # test "properly parses a comment" do
  #   sgf = "(;KM[6.5];C[Oh \\] hello])"
  #   collection = ExSgf.from_string(sgf)
  #   actual = List.first(collection.gametrees).nodes |> List.last
  #   expected = %{"C" => "Oh \\] hello"}
  #   assert expected == actual
  # end

  # test "handles branches" do
  #   sgf = "(;KM[6.5](;B[dd])(;B[cc]))"
  #   collection = ExSgf.from_string(sgf)
  #   nodes_under_root = List.first(collection.gametrees).nodes
  #   expected = [%{"B" => "dd"}, %{"B" => "cc"}]
  #   assert expected == nodes_under_root
  # end
end
