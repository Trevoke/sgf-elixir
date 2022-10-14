defmodule ExSgf do
  @moduledoc """
  Documentation for `ExSgf`.
  """

  alias ExSgf.Parser.Collection, as: CollectionParser

  @doc """
  Hello world.
  """
  def from_string(string) do
    CollectionParser.parse(string)
  end
end
