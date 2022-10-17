defmodule ExSgf.Accumulator do
  @moduledoc false

  defstruct current_node: nil,
            open_branches: 0,
            properties: nil,
            property_identity: "",
            property_value: nil,
            value_status: :closed,
            gametree_status: :closed
end
