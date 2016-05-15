alias Sgf.Node

defimpl Inspect, for: Node do
  def inspect(%Node{ident_props: props}, _) do
    props
    |> Map.keys
    |> Enum.reduce(";", fn(key, acc) ->
      stringified_vals = Map.get(props, key)
      |> Enum.reduce("", fn(val, acc) -> "#{acc}[#{val}]" end)

      "#{acc}#{to_string(key)}#{stringified_vals}"
    end)
  end
end
