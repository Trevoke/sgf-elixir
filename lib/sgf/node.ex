defmodule Sgf.Node do
  defstruct ident_props: %{}

  def parse_node(char_list) when is_list(char_list) do
    temp_props = char_list
    |> Stream.take_while(fn(char) -> char != ";" && char != "(" end)
    |> Enum.reduce(
      %{ ident_props: %{}, identity: "", current_val: ""},
      &read_char_to_node/2)

      %__MODULE__{ ident_props: temp_props.ident_props}
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
       fn(val) -> Enum.concat(val, [acc.current_val]) end)
    %{
      acc |
      ident_props: foo,
      current_val: ""
    }
  end
  defp read_char_to_node(char, acc), do: %{acc | current_val: acc.current_val <> char}
end
