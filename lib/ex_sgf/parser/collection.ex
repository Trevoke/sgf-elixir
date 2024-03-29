defmodule ExSgf.Parser.Collection do
  @moduledoc false
  alias RoseTree, as: RTree
  alias RoseTree.Zipper, as: Z
  alias ExSgf.Accumulator, as: A
  alias ExSgf.Parser.Gametree, as: GametreeParser
  @whitespace [" ", "\n", "\t"]

  @spec parse(binary()) :: {:ok, RoseTree.Zipper.t()}
  def parse(sgf) when is_binary(sgf), do: parse(sgf, %A{})

  @spec parse(binary(), A.t()) :: {:ok, RoseTree.Zipper.t()}
  def parse(sgf, %A{} = acc) when is_binary(sgf) do
    root = Z.from_tree(collection_root())
    acc = struct(acc, current_node: root)
    {"", acc} = parse_gametrees(sgf, acc)

    {:ok, Z.to_root(acc.current_node)}
  end

  @spec parse_gametrees(binary(), A.t()) :: {binary(), A.t()}
  def parse_gametrees("", acc), do: {"", acc}
  def parse_gametrees(" " <> rest, acc), do: parse_gametrees(rest, acc)
  def parse_gametrees("\n" <> rest, acc), do: parse_gametrees(rest, acc)
  def parse_gametrees("\t" <> rest, acc), do: parse_gametrees(rest, acc)

  def parse_gametrees(sgf, acc) do
    subtree_root = Z.from_tree(ExSgf.Node.new())

    new_acc =
      acc
      |> struct(gametree_status: :open)
      |> struct(current_node: subtree_root)

    {chunk, new_acc} = GametreeParser.parse(sgf, new_acc)

    {:ok, subtree} =
      new_acc.current_node
      |> Z.to_root()
      |> Z.first_child()
    subtree = Z.to_tree(subtree)

    {:ok, current_node} = Z.insert_last_child(acc.current_node, subtree)
    {:ok, current_node} = Z.ascend(current_node)

    parse_gametrees(chunk, struct(new_acc, current_node: current_node))
  end

  @spec collection_root() :: RTree.t()
  defp collection_root(), do: RTree.new(%{collection_root: true})
end
