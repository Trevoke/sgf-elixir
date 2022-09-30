defmodule ExSgf.Node do
  defstruct [next: [], properties: %{}, parent: nil, id: nil]

  def new(), do: %__MODULE__{id: make_ref()}
end
