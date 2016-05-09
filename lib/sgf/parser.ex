defmodule Sgf.Parser do
  alias Sgf.Node
  alias Sgf.Branch

  def parse(tree) do
    foo = tree
    |> parse_branch
    %Branch{ node_branches: foo }
  end

  def parse_branch("(" <> tail) do
     index = find_matching_close_parens(tail)
     parse(String.slice(tail, 0, index))
  end

  def parse_branch(";" <> tail) do
    Enum.take_while(tail, fn(x) -> x != "(" end)
    |> String.split(";")
    |> Enum.map(&parse_node/1)
  end

  def find_matching_close_parens(string) do
    String.split(string, "")
    |> Enum.reduce(%{depth: 0, index: 0}, &find_matching_parens/2)
  end

  defp find_matching_parens("(",                           acc), do: %{depth: acc.depth + 1, index: acc.index + 1}
  defp find_matching_parens(")",             %{depth: 0} = acc), do: %{matching_parens: acc.index}
  defp find_matching_parens(")",                           acc), do: %{depth: acc.depth - 1, index: acc.index + 1}
  defp find_matching_parens(_, %{matching_parens: index} = acc), do: acc
  defp find_matching_parens(_,                             acc), do: %{acc | index: acc.index + 1}

  def parse_node(char_list) when is_list(char_list) do
    temp_props = char_list
    |> Stream.take_while(fn(char) -> char != ";" && char != "(" end)
    |> Enum.reduce(
      %{ ident_props: %{}, identity: "", current_val: ""},
      &read_char_to_node/2)

      %Node{ ident_props: temp_props.ident_props}
  end

  def parse_node(node_string) when is_bitstring(node_string) do
    node_string
    |> String.split("")
    |> parse_node
  end

  defp read_char_to_node("[", %{current_val: ""} = acc), do: acc
  defp read_char_to_node("[", acc), do: %{acc | identity: String.to_atom(acc.current_val), current_val: ""}
  defp read_char_to_node("]", acc) do
      foo = Map.update(acc.ident_props,
       acc.identity,
       [acc.current_val],
       fn(val) -> val ++ acc.current_val end)
    %{
      acc |
      ident_props: foo,
      current_val: ""
    }
  end
  defp read_char_to_node(char, acc), do: %{acc | current_val: acc.current_val <> char}
end
