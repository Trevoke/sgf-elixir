defmodule ExSgf.Node do
  @moduledoc false

  alias RoseTree, as: RT

  def new(), do: new(%{})
  def new(%{} = props), do: RT.new(props)
end
