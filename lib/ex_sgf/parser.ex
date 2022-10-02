defmodule ExSgf.Parser do
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

  alias RoseTree, as: RTree
  alias RoseTree.Zipper, as: Zipper
  alias ExSgf.Accumulator, as: A

  defp new_node(), do: RTree.new(%{collection_root: true})
  defp new_node(%{} = props), do: RTree.new(props)

  def parse_collection(string), do: parse_collection(string, %A{})

  def parse_collection(string, acc) do
    root = new_node() |> Zipper.from_tree()

    acc =
      acc
      |> Map.put(:current_node, root)
      |> Map.put(:open_branches, 0)

    {"", acc} = parse_gametrees(string, acc)

    {:ok, acc.current_node |> Zipper.to_root}
  end

  def parse_gametrees("", acc), do: {"", acc}
  def parse_gametrees(<<" ", rest::binary>>, acc), do: parse_gametrees(rest, acc)
  def parse_gametrees(<<"\n", rest::binary>>, acc), do: parse_gametrees(rest, acc)
  def parse_gametrees(<<"\t", rest::binary>>, acc), do: parse_gametrees(rest, acc)

  def parse_gametrees(string, acc) do
    {string, acc} = parse_gametree(string, acc)
    root = Zipper.to_root(acc.current_node)
    parse_gametrees(string, Map.put(acc, :current_node, root))
  end

  def parse_gametree("", acc), do: {"", acc}
  def parse_gametree(<<"\n", rest::binary>>, acc), do: parse_gametree(rest, acc)
  def parse_gametree(<<" ", rest::binary>>, acc), do: parse_gametree(rest, acc)
  def parse_gametree(<<"\t", rest::binary>>, acc), do: parse_gametree(rest, acc)

  def parse_gametree(<<@open_branch, rest::binary>>, %{} = acc) do
    acc = Map.put(acc, :open_branches, acc.open_branches + 1)


    parse_sequence(rest, acc)

  end

  def parse_gametree(
        <<@close_branch, rest::binary>>,
        %{current_node: current_node, open_branches: 0} = acc
      ) do
    {:ok, root} = Zipper.ascend(acc.current_node)
    {rest, Map.put(acc, :current_node, root)}
  end

  def parse_gametree(<<@close_branch, rest::binary>>, %{} = acc) do
    current_node = Map.get(acc, :current_node)

    current_node =
      if Zipper.has_parent?(current_node) do
        Zipper.ascend(current_node) |> elem(1)
      else
        current_node
      end

    acc =
      acc
      |> Map.put(:open_branches, acc.open_branches - 1)
      |> Map.put(:current_node, current_node)

    parse_sequence(rest, acc)
  end

  def parse_sequence(<<"\n", rest::binary>>, acc), do: parse_sequence(rest, acc)
  def parse_sequence(<<" ", rest::binary>>, acc), do: parse_sequence(rest, acc)
  def parse_sequence(<<"\t", rest::binary>>, acc), do: parse_sequence(rest, acc)

  def parse_sequence("", acc), do: {"", acc}

  def parse_sequence(<<@open_branch, rest::binary>> = string, acc) do
    parse_gametree(string, acc)
  end

  def parse_sequence(<<@close_branch, rest::binary>> = string, acc) do
    parse_gametree(string, acc)
  end

  def parse_sequence(string, %{} = acc) do
    {rest, node1} = parse_node(string, acc)

    current_node = maybe_add_child(Map.get(acc, :current_node, nil), node1)

    acc = Map.put(acc, :current_node, current_node)
    parse_sequence(rest, acc)
  end

  def parse_node(<<"\n", rest::binary>>, acc), do: parse_node(rest, acc)
  def parse_node(<<" ", rest::binary>>, acc), do: parse_node(rest, acc)
  def parse_node(<<"\t", rest::binary>>, acc), do: parse_node(rest, acc)

  def parse_node(<<@new_node, rest::binary>>, %{} = acc) do
    {properties, rest} = parse_properties(rest, Map.put(acc, :properties, %{}))
    node1 = new_node(properties)

    {rest, node1}
  end

  def parse_properties(<<@new_node, rest::binary>>, %{properties: properties} = acc) do
    {properties, @new_node <> rest}
  end

  def parse_properties(<<@open_branch, rest::binary>>, %{properties: properties} = acc) do
    {properties, @open_branch <> rest}
  end

  def parse_properties(<<@close_branch, rest::binary>>, %{properties: properties} = acc) do
    {properties, @close_branch <> rest}
  end

  def parse_properties("", %{properties: properties}), do: {properties, ""}

  def parse_properties(rest, %{properties: properties} = acc) do
    {identity, rest} = parse_property_identity(rest, acc)

    if identity == :no_prop do
      {properties, rest}
    else
      acc =
        acc
        |> Map.delete(:property_identity)
        |> Map.put(:property_value, [])
        |> Map.put(:value_status, :closed)

      {value, rest} = parse_property_value(rest, acc)
      properties = Map.put(properties, identity, value)
      parse_properties(rest, Map.put(acc, :properties, properties))
    end
  end

  def parse_property_identity(<<@close_branch, rest::binary>> = string, acc), do: {:no_prop, string}
  def parse_property_identity(<<@new_node, rest::binary>> = string, acc), do: {:no_prop, string}

  def parse_property_identity(<<"\n", rest::binary>>, acc), do: parse_property_identity(rest, acc)
  def parse_property_identity(<<" ", rest::binary>>, acc), do: parse_property_identity(rest, acc)
  def parse_property_identity(<<"\t", rest::binary>>, acc), do: parse_property_identity(rest, acc)

  def parse_property_identity(<<@open_value, _rest::binary>> = string, %{} = acc) do
    {acc.property_identity, string}
  end

  def parse_property_identity(<<x::utf8, rest::binary>>, %A{} = acc) do
    parse_property_identity(
      rest,
      Map.update(
        acc,
        :property_identity,
        List.to_string([x]),
        fn val -> val <> List.to_string([x]) end
      )
    )
  end

  def parse_property_value("", %{property_value: x}) do
    {Enum.reverse(x), ""}
  end

  def parse_property_value(<<" ", rest::binary>>, %{value_status: :closed} = acc) do
    parse_property_value(rest, acc)
  end
  def parse_property_value(<<"\n", rest::binary>>, %{value_status: :closed} = acc) do
    parse_property_value(rest, acc)
  end
  def parse_property_value(<<"\t", rest::binary>>, %{value_status: :closed} = acc) do
    parse_property_value(rest, acc)
  end
  def parse_property_value(
        <<@open_value, rest::binary>>,
        %{property_value: value, value_status: :closed} = acc
      ) do
    acc =
      acc
      |> Map.put(:property_value, ["" | value])
      |> Map.put(:value_status, :open)

    parse_property_value(rest, acc)
  end

  def parse_property_value(
        <<x::utf8, rest::binary>>,
        %{property_value: value, value_status: :closed} = acc
      ) do
    {value, List.to_string([x]) <> rest}
  end

  def parse_property_value(<<@close_value, rest::binary>>, %{value_status: :open} = acc) do
    parse_property_value(rest, Map.put(acc, :value_status, :closed))
  end

  def parse_property_value(
        <<"\\]", rest::binary>>,
        %{property_value: [h | t], value_status: :open} = acc
      ) do
    value = [h <> "\\]" | t]
    parse_property_value(rest, Map.put(acc, :property_value, value))
  end

  def parse_property_value(
        <<x::utf8, rest::binary>>,
        %{property_value: [h | t], value_status: :open} = acc
      ) do
    value = [h <> List.to_string([x]) | t]
    parse_property_value(rest, Map.put(acc, :property_value, value))
  end

  def maybe_add_child(nil, {%RoseTree{}, _} = zipper), do: zipper
  def maybe_add_child(nil, node1), do: RoseTree.Zipper.from_tree(node1)

  def maybe_add_child({%RoseTree{}, _} = zipper, node1) do
    {:ok, zipper} = Zipper.insert_last_child(zipper, node1)
    zipper
  end
end
