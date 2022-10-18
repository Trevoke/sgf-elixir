defmodule ExSgf.Accumulator do
  @moduledoc false

  @type status :: :closed | :open
  @type property_value :: binary() | nil
  @type sgf_node :: RoseTree.Zipper.t() | nil

  defstruct current_node: nil,
            open_branches: 0,
            properties: %{},
            property_identity: "",
            property_value: nil,
            value_status: :closed,
            gametree_status: :closed

  @type t :: %__MODULE__{
          current_node: sgf_node,
          open_branches: non_neg_integer(),
          properties: map(),
          property_identity: binary(),
          property_value: property_value,
          value_status: status,
          gametree_status: status
        }
end
