defmodule ExSgf do
  @moduledoc """
  Documentation for `ExSgf`.
  """

  alias ExSgf.Parser.Collection, as: CollectionParser

  @doc """
  Hello world.
  """
  @spec from_string(String.t()) :: {:ok, RoseTree.Zipper.t()}
  def from_string(string) do
    CollectionParser.parse(string)
  end
end
