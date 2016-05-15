defmodule Sgf.Parser do
  alias Sgf.Node
  alias Sgf.Branch
  alias Sgf.StringHelper

  def parse(tree) do
    foo = tree
    |> parse_branch
    %Branch{ node_branches: foo }
  end

  def parse_branch("(" <> tail) do
     index = StringHelper.find_matching_close_paren(tail)
     parse(String.slice(tail, 0, index))
  end

  def parse_branch(";" <> tail) do
    Enum.take_while(tail, fn(x) -> x != "(" end)
    |> String.split(";")
    |> Enum.map(&Node.parse_node/1)
  end
end
