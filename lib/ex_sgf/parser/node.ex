defmodule ExSgf.Parser.Node do
  @moduledoc false
  alias ExSgf.Accumulator, as: A
  alias ExSgf.Parser.Properties, as: PropertiesParser
  @whitespace [" ", "\n", "\t"]
  @new_node ";"
  @open_branch "("
  @close_branch ")"
  @end_of_file false
  @node_delimiters [@new_node, @open_branch, @close_branch, @end_of_file]
  @open_value "["
  @close_value "]"
  @list_identities [
    "AW",
    "AB",
    "AE",
    "AR",
    "CR",
    "DD",
    "LB",
    "LN",
    "MA",
    "SL",
    "SQ",
    "TR",
    "VW",
    "TB",
    "TW"
  ]

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
