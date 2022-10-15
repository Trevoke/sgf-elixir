defmodule ExSgf.Parser.Gametree do
  alias RoseTree.Zipper, as: Zipper
  alias ExSgf.Accumulator, as: A
  alias ExSgf.Parser.Sequence, as: SequenceParser
  @open_branch "("
  @close_branch ")"

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
      |> Zipper.first_child
      |> Zipper.lift(&Zipper.to_tree/1)

    {:ok, current_node} =
      acc.current_node
      |> Zipper.insert_last_child(subtree)
      |> Zipper.lift(&Zipper.ascend/1)

    parse(rest, Map.put(new_acc, :current_node, current_node))
  end

  def parse(<<@close_branch, rest::binary>> = chunk, %A{open_branches: 1} = acc) do
    zipper = Zipper.to_root(acc.current_node)
    {rest, Map.put(acc, :current_node, zipper)}
  end

  def parse(<<@close_branch, rest::binary>> = chunk, acc) do
    acc = Map.put(acc, :open_branches, acc.open_branches - 1)
    parse(rest, acc)
  end

end