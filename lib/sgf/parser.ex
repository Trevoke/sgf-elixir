defmodule Sgf.Parser do
  alias Sgf.Node
  alias Sgf.Branch
  alias Sgf.StringHelper

  def parse(tree) when is_bitstring(tree) do
    tree
    |> String.graphemes
    |> parse(%{variation_count: 0})
    |> branchify
  end

  def parse(["(" | tail], %{variation_count: variation_count } = acc) do
    parse(tail, %{variation_count: variation_count + 1})
  end

  def parse([")" | tail], %{variation_count: variation_count } = acc) do
    parse(tail, %{acc |
                  variation_count: variation_count - 1,
                  })
  end

  def parse([";" | tail], acc) do
    {:ok, node, length} = Sgf.Node.parse_node(tail)
    parse(Enum.drop(tail, length), Map.merge(acc, %{node: node}))
  end

  def parse([], acc), do: acc

  def parse(oops, aaps), do: IO.inspect aaps

  defp branchify(node_branches), do: %Branch{ node_branches: [node_branches.node] }
end
