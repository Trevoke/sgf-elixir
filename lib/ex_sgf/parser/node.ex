defmodule ExSgf.Parser.Node do
  @moduledoc false
  alias ExSgf.Accumulator, as: A
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

  def parse(<<"\n", rest::binary>>, acc), do: parse(rest, acc)
  def parse(<<" ", rest::binary>>, acc), do: parse(rest, acc)
  def parse(<<"\t", rest::binary>>, acc), do: parse(rest, acc)

  def parse(<<@new_node, rest::binary>>, %{} = acc) do
    {properties, rest} = parse_properties(rest, Map.put(acc, :properties, %{}))
    node1 = ExSgf.Node.new(properties)
    {rest, node1}
  end

  def parse_properties(<<@new_node, rest::binary>>, %A{properties: properties}) do
    {properties, @new_node <> rest}
  end

  def parse_properties(<<@open_branch, rest::binary>>, %A{properties: properties}) do
    {properties, @open_branch <> rest}
  end

  def parse_properties(<<@close_branch, rest::binary>>, %A{properties: properties}) do
    {properties, @close_branch <> rest}
  end

  def parse_properties("", %A{properties: properties}), do: {properties, ""}

  def parse_properties(rest, %A{properties: properties} = acc) do
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

  def parse_property_identity(<<@close_branch, _rest::binary>> = chunk, _acc),
    do: {:no_prop, chunk}

  def parse_property_identity(<<@new_node, _rest::binary>> = chunk, _acc), do: {:no_prop, chunk}

  def parse_property_identity(<<"\n", rest::binary>>, acc), do: parse_property_identity(rest, acc)
  def parse_property_identity(<<" ", rest::binary>>, acc), do: parse_property_identity(rest, acc)
  def parse_property_identity(<<"\t", rest::binary>>, acc), do: parse_property_identity(rest, acc)

  def parse_property_identity(<<@open_value, _rest::binary>> = chunk, %{} = acc) do
    {acc.property_identity, chunk}
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
        %{property_value: value, value_status: :closed}
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
end
