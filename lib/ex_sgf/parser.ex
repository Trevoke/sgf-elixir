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
    {gametree, rest} = parse_gametree(%GameTree{}, rest, %{open_branches: 0})
    nodes = Enum.reverse(gametree.nodes)
    gametree = Map.put(gametree, :nodes, nodes)
    c = Map.put(c, :gametrees, [gametree | c.gametrees])
    generate_gametrees(c, rest)
  end

  def parse_gametree(gametree, "", _acc), do: {gametree, ""}
  def parse_gametree(gametree, <<@new_node, rest::binary>>, acc) do
    {nodes, rest} = parse_nodes(%{}, rest, Map.put(acc, :nodes, []))
    acc = Map.put(acc, :nodes, [])
    parse_gametree(%{gametree | nodes: nodes}, rest, acc)
  end

  # use put_node everywhere?

  # close gametree
  def parse_nodes(current_node, <<@close_branch, rest::binary>>, %{open_branches: 0} = acc) do
    acc = %{acc | nodes: [current_node | acc.nodes]}
    {acc.nodes, rest}
  end

  def parse_nodes(current_node, <<@close_branch, rest::binary>>, acc) do
    nodes = put_node(current_node, acc.nodes, acc.open_branches)
    acc = %{acc | nodes: nodes,
           open_branches: acc.open_branches - 1}
    parse_nodes(current_node, rest, acc)
  end

  def parse_nodes(current_node, <<@open_branch, rest::binary>>, acc) do
    acc = %{acc | nodes: [[] | acc.nodes],
            open_branches: acc.open_branches + 1}
    parse_nodes(current_node, rest, acc)
  end

  def parse_nodes(current_node, string, acc) do
    {property, string} = parse_property(string, "")

    if property == "" do
      parse_nodes(%{}, string, acc)
    else

    {value, string} = parse_value(string, "")

    current_node = Map.put(current_node, property, value)
    parse_nodes(current_node, string, acc)
    end
  end

  def parse_property(<<" ", rest::binary>>, acc), do: parse_property(rest, acc)
  def parse_property(<<"\n", rest::binary>>, acc), do: parse_property(rest, acc)
  def parse_property(<<@open_value, rest::binary>>, acc), do: {acc, rest}

  def parse_property(<<x::utf8, rest::binary>>, acc) do
    char = List.to_string([x])
    if char in @node_delimiters do
      {"", rest}
    else
      parse_property(rest, acc <> List.to_string([x]))
    end
  end

  def parse_value(<<"\\]", rest::binary>>, acc) do
    parse_value(rest, acc <> "\\]")
  end

  def parse_value(<<@close_value, rest::binary>>, acc), do: {acc, rest}

  def parse_value(<<x::utf8, rest::binary>>, acc) do
    parse_value(rest, acc <> List.to_string([x]))
  end

  def put_node(node, nodes, 0) do
    [node | nodes]
  end

  def put_node(node, [h | t], x) do
    [put_node(node, h, x - 1) | t]
  end

end
