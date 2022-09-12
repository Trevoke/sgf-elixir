defmodule ExSgf.Parser do
  alias ExSgf.{Collection, GameTree}
  @new_node  ";"
  @open_branch "("
  @close_branch ")"
  @end_of_file false
  @node_delimiters [@new_node, @open_branch, @close_branch, @end_of_file]
  @open_value "["
  @close_value "]"
  @list_identities ["AW", "AB", "AE", "AR", "CR", "DD", "LB",
                    "LN", "MA", "SL", "SQ", "TR", "VW", "TB", "TW"]

  def generate_collection(c, string) do
    c = generate_gametrees(c, string)
    gametrees = Enum.reverse(c.gametrees)
    Map.put(c, :gametrees, gametrees)
  end

  def generate_gametrees(c, <<" ", rest::binary >>), do: generate_gametrees(c, rest)
  def generate_gametrees(c, <<"\n", rest::binary >>), do: generate_gametrees(c, rest)
  def generate_gametrees(c, ""), do: c
  def generate_gametrees(c, <<"(", rest::binary>> ) do
    {gametree, rest} = parse_nodes(%GameTree{}, rest, %{open_branches: 0})
    nodes = Enum.reverse(gametree.nodes)
    Map.put(gametree, :nodes, nodes)
    c = Map.put(c, :gametrees, [gametree | c.gametrees])
    generate_gametrees(c, rest)
  end
  def parse_nodes(gametree, "", _acc), do: {gametree, ""}
  def parse_nodes(gametree, <<@new_node, rest::binary>>, acc) do
    node = %{}
    {node, rest} = parse_node(node, rest, acc)
    gametree = %{gametree | nodes: [node | gametree.nodes]}
    parse_nodes(gametree, rest, acc)
  end

  # .. also close gametree?
  #def parse_nodes(gametree, <<@close_branch, rest::binary>>, %{open_branches: 0}) do
  #  {gametree, rest}
  #end

  # close gametree
  def parse_node(node, <<@close_branch, rest::binary>>, %{open_branches: 0}) do
    {node, rest}
  end

  def parse_node(node, string, acc) do
    {property, string} = parse_property(string, "")
    {value, string} = parse_value(string, "")
    node = Map.put(node, property, value)
    parse_node(node, string, acc)
  end

  def parse_property(<<@open_value, rest::binary>>, property) do
    {property, rest}
  end

  def parse_property(<<x::utf8, rest::binary>>, acc) do
    parse_property(rest, acc <> List.to_string([x]))
  end

  def parse_value(<<"\\]", rest::binary>>, acc) do
    parse_value(rest, acc <> "\\]")
  end

  def parse_value(<<@close_value, rest::binary>>, acc) do
    {acc, rest}
  end

  def parse_value(<<x::utf8, rest::binary>>, acc) do
    parse_value(rest, acc <> List.to_string([x]))
  end

end
