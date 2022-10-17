defmodule ExSgf.Parser.Gametree do
  alias RoseTree.Zipper, as: Zipper
  alias ExSgf.Accumulator, as: A
  alias ExSgf.Parser.Sequence, as: SequenceParser
  @open_branch "("
  @close_branch ")"

  def parse(sgf, %A{gametree_status: :closed} = acc), do: {sgf, acc}
  def parse("", acc), do: {"", acc}
  def parse(<<"\n", rest::binary>>, acc), do: parse(rest, acc)
  def parse(<<" ", rest::binary>>, acc), do: parse(rest, acc)
  def parse(<<"\t", rest::binary>>, acc), do: parse(rest, acc)

  def parse(<<@open_branch, rest::binary>>, %A{} = acc) do
    acc = Map.put(acc, :open_branches, acc.open_branches + 1)
    new_zipper = Zipper.from_tree(ExSgf.Node.new)
    {rest, new_acc} = SequenceParser.parse(rest, Map.put(acc, :current_node, new_zipper))

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
      |> Map.put(:open_branches, new_acc.open_branches - 1)

    parse(rest, new_acc)
  end

  def parse(<<@close_branch, rest::binary>> = chunk, %A{open_branches: 0} = acc) do

    acc =
      acc
      |> Map.put(:gametree_status, :closed)
    {rest, acc}
  end

  def parse(<<@close_branch, rest::binary>> = chunk, acc) do
    IO.inspect acc
    parse(rest, acc)
  end

end