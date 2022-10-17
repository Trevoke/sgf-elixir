defmodule ExSgf.Accumulator do
  @moduledoc false

  @type status :: :closed | :open
  @type property_value :: String.t() | nil
  @type properties :: map() | nil

  defstruct current_node: nil,
            open_branches: 0,
            properties: nil,
            property_identity: "",
            property_value: nil,
            value_status: :closed,
            gametree_status: :closed

  @type t :: %__MODULE__{
          current_node: RoseTree.Zipper.t(),
          open_branches: non_neg_integer(),
          properties: properties,
          property_identity: String.t(),
          property_value: property_value,
          value_status: status,
          gametree_status: status
        }
end
