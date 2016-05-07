defmodule Sgf.Parser do
  import Regex
  require IEx
  alias Sgf.Node

  def parse(tree) do
    [ [_, branch] | _]  = Regex.scan(~r/\((.*)\)/, tree)
    parse_branch branch
  end

  def parse_node(node_string) do
    # %{
      # indentProps
      # currentVal partial ident or partial prop
      # }
    temp_props = node_string
      |> String.split("")
      |> Enum.reduce(
        %{ ident_props: %{}, identity: "", current_val: ""},
        &read_char_to_node/2
      )

      %Node{ ident_props: temp_props.ident_props}
  end

  defp read_char_to_node("[", acc) do
     if (acc.current_val == "") do
       acc
     else
      %{acc | identity: String.to_atom(acc.current_val), current_val: ""}
     end
  end

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

  defp read_char_to_node(char, acc) do
      %{acc | current_val: acc.current_val <> char}
  end

  defp parse_branch(branch) do
    [_ | nodes] = String.split(branch, ";")
    #properties = Enum.map(nodes, fn element -> Regex.scan(~r/(\w?*)(\[.*\])/, element))
  end
end

