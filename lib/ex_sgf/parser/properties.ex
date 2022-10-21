defmodule ExSgf.Parser.Properties do
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

  alias ExSgf.Accumulator, as: A

  def parse(<<@new_node, rest::binary>>, %A{properties: properties}) do
    {properties, @new_node <> rest}
  end

  def parse(<<@open_branch, rest::binary>>, %A{properties: properties}) do
    {properties, @open_branch <> rest}
  end

  def parse(<<@close_branch, rest::binary>>, %A{properties: properties}) do
    {properties, @close_branch <> rest}
  end

  def parse("", %A{properties: properties}), do: {properties, ""}

  def parse(rest, %A{properties: properties} = acc) do
    {identity, rest} = parse_identity(rest, acc)

    if identity == :no_prop do
      {properties, rest}
    else
      acc =
        acc
        |> struct(property_identity: "")
        |> struct(property_value: [])
        |> struct(value_status: :closed)

      {value, rest} = parse_value(rest, acc)

      value =
        if Enum.member?(@list_identities, identity) do
          value
        else
          List.first(value)
        end

      properties = Map.put(properties, identity, value)
      parse(rest, struct(acc, properties: properties))
    end
  end

  def parse_identity(<<@close_branch, _rest::binary>> = chunk, _acc),
    do: {:no_prop, chunk}

  def parse_identity(<<@new_node, _rest::binary>> = chunk, _acc), do: {:no_prop, chunk}

  def parse_identity(<<"\n", rest::binary>>, acc), do: parse_identity(rest, acc)
  def parse_identity(<<" ", rest::binary>>, acc), do: parse_identity(rest, acc)
  def parse_identity(<<"\t", rest::binary>>, acc), do: parse_identity(rest, acc)

  def parse_identity(<<@open_value, _rest::binary>> = chunk, %{} = acc) do
    {acc.property_identity, chunk}
  end

  def parse_identity(<<x::utf8, rest::binary>>, %A{} = acc) do
    parse_identity(
      rest,
      Map.update(
        acc,
        :property_identity,
        List.to_string([x]),
        fn val -> val <> List.to_string([x]) end
      )
    )
  end

  def parse_value("", %{property_value: x}) do
    {Enum.reverse(x), ""}
  end

  def parse_value(<<" ", rest::binary>>, %{value_status: :closed} = acc) do
    parse_value(rest, acc)
  end

  def parse_value(<<"\n", rest::binary>>, %{value_status: :closed} = acc) do
    parse_value(rest, acc)
  end

  def parse_value(<<"\t", rest::binary>>, %{value_status: :closed} = acc) do
    parse_value(rest, acc)
  end

  def parse_value(
        <<@open_value, rest::binary>>,
        %{property_value: value, value_status: :closed} = acc
      ) do
    acc =
      acc
      |> struct(property_value: ["" | value])
      |> struct(value_status: :open)

    parse_value(rest, acc)
  end

  def parse_value(
        <<x::utf8, rest::binary>>,
        %{property_value: value, value_status: :closed}
      ) do
    {value, List.to_string([x]) <> rest}
  end

  def parse_value(<<@close_value, rest::binary>>, %{value_status: :open} = acc) do
    parse_value(rest, struct(acc, value_status: :closed))
  end

  def parse_value(
        <<"\\]", rest::binary>>,
        %{property_value: [h | t], value_status: :open} = acc
      ) do
    value = [h <> "\\]" | t]
    parse_value(rest, struct(acc, property_value: value))
  end

  def parse_value(
        <<x::utf8, rest::binary>>,
        %{property_value: [h | t], value_status: :open} = acc
      ) do
    value = [h <> List.to_string([x]) | t]
    parse_value(rest, struct(acc, property_value: value))
  end
end
