defmodule ExSgf.Parser.Collection do
  alias RoseTree, as: RTree
  alias RoseTree.Zipper, as: Z
  alias ExSgf.Accumulator, as: A
  alias ExSgf.Parser.Gametree, as: GametreeParser
  @whitespace [" ", "\n", "\t"]
  @new_node ";"
  @open_branch "("
  @close_branch ")"
  @end_of_file false
  @node_delimiters [@new_node, @open_branch, @close_branch, @end_of_file]
  @open_value "["
  @close_value "]"
  @list_identities [
    "AW",
    "AB",
    "AE",
    "AR",
    "CR",
    "DD",
    "LB",
    "LN",
    "MA",
    "SL",
    "SQ",
    "TR",
    "VW",
    "TB",
    "TW"
  ]


  def parse(sgf), do: parse(sgf, %A{})

  def parse(sgf, acc) do
    root = Z.from_tree(collection_root())
    acc = Map.put(acc, :current_node, root)

    {"", acc} = parse_gametrees(sgf, acc)

    {:ok, Z.to_root(acc.current_node)}
  end

  def parse_gametrees("", acc), do: {"", acc}
  def parse_gametrees(<<" ", rest::binary>>, acc), do: parse_gametrees(rest, acc)
  def parse_gametrees(<<"\n", rest::binary>>, acc), do: parse_gametrees(rest, acc)
  def parse_gametrees(<<"\t", rest::binary>>, acc), do: parse_gametrees(rest, acc)

  def parse_gametrees(sgf, acc) do
    subtree_root = ExSgf.Node.new |> Z.from_tree()
    {chunk, new_acc} = GametreeParser.parse(sgf, Map.put(acc, :current_node, subtree_root))

    IO.inspect chunk
    IO.inspect new_acc.current_node

    subtree =
      new_acc.current_node
      |> Z.to_root
      |> Z.first_child
      |> Z.lift(&Z.to_tree/1)

    {:ok, current_node} =
      acc.current_node
      |> Z.insert_last_child(subtree)
      |> Z.lift(&Z.ascend/1)

    parse_gametrees(chunk, Map.put(new_acc, :current_node, current_node))
  end

  defp collection_root(), do: RTree.new(%{collection_root: true})
end