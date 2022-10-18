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

    parse(rest, new_acc)
  end
end
