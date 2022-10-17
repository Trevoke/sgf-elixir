defmodule ExSgf.Parser.Gametree do
  alias RoseTree.Zipper, as: Zipper
  alias ExSgf.Accumulator, as: A
  alias ExSgf.Parser.Sequence, as: SequenceParser
  @open_branch "("
  @close_branch ")"

  def parse("", acc), do: {"", acc}
  def parse(sgf, %A{gametree_status: :closed} = acc), do: {sgf, acc}
  def parse(<<@close_branch, rest::binary>> = chunk, %A{open_branches: 1} = acc) do
    acc =
      acc
      |> Map.put(:open_branches, acc.open_branches - 1)
      |> Map.put(:gametree_status, :closed)
    {rest, acc}
  end
  def parse(<<@close_branch, rest::binary>> = chunk, %A{} = acc) do
    acc =
      acc
      |> Map.put(:open_branches, acc.open_branches - 1)
    parse(rest, acc)
  end

  def parse(<<"\n", rest::binary>>, acc), do: parse(rest, acc)
  def parse(<<" ", rest::binary>>, acc), do: parse(rest, acc)
  def parse(<<"\t", rest::binary>>, acc), do: parse(rest, acc)

  def parse(<<@open_branch, rest::binary>>, %A{} = acc) do
    new_zipper = Zipper.from_tree(ExSgf.Node.new)
    new_acc =
      acc
      |> Map.put(:open_branches, acc.open_branches + 1)
      |> Map.put(:current_node, new_zipper)

    {rest, new_acc} = SequenceParser.parse(rest, new_acc)

    subtree =
      new_acc.current_node
      |> Zipper.to_root
      |> Zipper.first_child
      |> Zipper.lift(&Zipper.to_tree/1)

    {:ok, current_node} =
      acc.current_node
      |> Zipper.insert_last_child(subtree)
      |> Zipper.lift(&Zipper.ascend/1)

    new_acc =
      new_acc
      |> Map.put(:current_node, current_node)

    parse(rest, new_acc)
  end
end