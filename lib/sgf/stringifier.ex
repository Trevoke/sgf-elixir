defmodule Sgf.Stringifier do

  @beginning_of_node ";"

  def node(properties) do
    @beginning_of_node <> Enum.map_join(properties, "\n", &(_node &1))
  end

  defp _node({"C", comment}) do
    "C[#{String.replace(comment, "]", "\\]")}]"
  end

  defp _node({attribute, property}) do
    "#{String.upcase(attribute)}[#{property}]"
  end
end


