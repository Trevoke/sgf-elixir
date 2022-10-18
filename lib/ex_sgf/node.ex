defmodule ExSgf.Node do
  @moduledoc false

  alias RoseTree, as: RT

  @spec new() :: RoseTree.t()
  def new(), do: new(%{})

  @spec new(map()) :: RoseTree.t()
  def new(%{} = props), do: RT.new(props)
end
