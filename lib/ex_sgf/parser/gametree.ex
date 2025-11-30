defmodule ExSgf.Parser.Gametree do
  @moduledoc false
  alias RoseTree.Zipper
  alias ExSgf.Accumulator, as: A
  alias ExSgf.Parser.Sequence, as: SequenceParser
  @open_branch "("
  @close_branch ")"

  @spec parse(binary(), A.t()) :: {binary(), A.t()}
  def parse("", acc), do: {"", acc}
  def parse(sgf, %A{gametree_status: :closed} = acc), do: {sgf, acc}

  def parse(<<@close_branch, rest::binary>>, %A{open_branches: 1} = acc) do
    acc =
      acc
      |> struct(open_branches: acc.open_branches - 1)
      |> struct(gametree_status: :closed)

    {rest, acc}
  end

  def parse(<<@close_branch, rest::binary>>, %A{} = acc) do
    acc = struct(acc, open_branches: acc.open_branches - 1)

    parse(rest, acc)
  end

  def parse(<<"\n", rest::binary>>, acc), do: parse(rest, acc)
  def parse(<<" ", rest::binary>>, acc), do: parse(rest, acc)
  def parse(<<"\t", rest::binary>>, acc), do: parse(rest, acc)

  def parse(<<@open_branch, rest::binary>>, %A{} = acc) do
    # Remember the depth before this branch (used to know when to return)
    starting_depth = acc.open_branches

    new_zipper = Zipper.from_tree(ExSgf.Node.new())

    new_acc =
      acc
      |> struct(open_branches: acc.open_branches + 1)
      |> struct(current_node: new_zipper)

    {rest, new_acc} = SequenceParser.parse(rest, new_acc)

    {:ok, subtree} =
      new_acc.current_node
      |> Zipper.to_root()
      |> Zipper.first_child()
    subtree = Zipper.to_tree(subtree)

    {:ok, current_node} =
      acc.current_node
      |> Zipper.insert_last_child(subtree)
      |> Zipper.lift(&Zipper.ascend/1)

    new_acc = struct(new_acc, current_node: current_node)

    # Continue processing rest, but return when we hit ) that closes back to starting depth
    parse_until_depth(rest, new_acc, starting_depth)
  end

  # Parse until we've closed this branch (back to starting_depth)
  defp parse_until_depth("", acc, _starting_depth), do: {"", acc}

  defp parse_until_depth(<<@close_branch, rest::binary>>, %A{open_branches: ob} = acc, starting_depth)
       when ob == starting_depth + 1 do
    # This ) closes THIS branch - consume it and return
    acc = struct(acc, open_branches: starting_depth)
    {rest, acc}
  end

  defp parse_until_depth(<<@close_branch, rest::binary>>, acc, starting_depth) do
    # This ) is for more deeply nested content, decrement and continue
    acc = struct(acc, open_branches: acc.open_branches - 1)
    parse_until_depth(rest, acc, starting_depth)
  end

  defp parse_until_depth(<<@open_branch, _rest::binary>> = chunk, acc, starting_depth) do
    # Another branch at this level - process it
    {rest, acc} = parse(chunk, acc)
    parse_until_depth(rest, acc, starting_depth)
  end

  defp parse_until_depth(<<"\n", rest::binary>>, acc, sd), do: parse_until_depth(rest, acc, sd)
  defp parse_until_depth(<<" ", rest::binary>>, acc, sd), do: parse_until_depth(rest, acc, sd)
  defp parse_until_depth(<<"\t", rest::binary>>, acc, sd), do: parse_until_depth(rest, acc, sd)
end
