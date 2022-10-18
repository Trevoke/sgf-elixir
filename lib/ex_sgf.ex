defmodule ExSgf do
  @moduledoc """
  Documentation for `ExSgf`.
  """

  alias ExSgf.Parser.Collection, as: CollectionParser


  @spec from_string(binary()) :: {:ok, RoseTree.Zipper.t()}
  def from_string(string) when is_binary(string) do
    CollectionParser.parse(string)
  end
end
