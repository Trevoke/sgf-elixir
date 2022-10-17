defmodule ExSgf.Parser.Sequence do
  @moduledoc false
  alias RoseTree, as: RTree
  alias RoseTree.Zipper
  alias ExSgf.Accumulator, as: A
  alias ExSgf.Parser.Gametree, as: GametreeParser
  alias ExSgf.Parser.Node, as: NodeParser
  @whitespace [" ", "\n", "\t"]
  @new_node ";"
  @open_branch "("
  @close_branch ")"
  @node_delimiters [@new_node, @open_branch, @close_branch]

  def parse(<<"\n", rest::binary>>, acc), do: parse(rest, acc)
  def parse(<<" ", rest::binary>>, acc), do: parse(rest, acc)
  def parse(<<"\t", rest::binary>>, acc), do: parse(rest, acc)

  def parse("", acc), do: {"", acc}

  def parse(<<@open_branch, _rest::binary>> = chunk, acc) do
    # GametreeParser.parse(chunk, Map.put(acc, :open_branches, 0))
    GametreeParser.parse(chunk, acc)
    # {chunk, acc}
  end

  def parse(<<@close_branch, _rest::binary>> = chunk, %A{} = acc) do
    {chunk, acc}
  end

  def parse(<<@new_node, _rest::binary>> = chunk, %A{current_node: current_node} = acc) do
    {rest, node1} = NodeParser.parse(chunk, acc)
    {:ok, zipper} = Zipper.insert_last_child(current_node, node1)

    acc = Map.put(acc, :current_node, zipper)
    parse(rest, acc)
  end
end
