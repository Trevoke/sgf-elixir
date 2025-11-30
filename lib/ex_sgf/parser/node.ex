defmodule ExSgf.Parser.Node do
  @moduledoc false
  alias ExSgf.Accumulator, as: A
  alias ExSgf.Parser.Properties, as: PropertiesParser
  @new_node ";"

  @spec parse(binary(), A.t()) :: {binary(), RoseTree.t()}
  def parse(<<"\n", rest::binary>>, acc), do: parse(rest, acc)
  def parse(<<" ", rest::binary>>, acc), do: parse(rest, acc)
  def parse(<<"\t", rest::binary>>, acc), do: parse(rest, acc)

  def parse(<<@new_node, rest::binary>>, %{} = acc) do
    {properties, rest} = PropertiesParser.parse(rest, struct(acc, properties: %{}))
    node1 = ExSgf.Node.new(properties)
    {rest, node1}
  end

end
