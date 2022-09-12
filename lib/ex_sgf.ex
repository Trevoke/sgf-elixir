defmodule ExSgf do
  @moduledoc """
  Documentation for `ExSgf`.
  """

  alias ExSgf.{Collection,GameTree, Parser}

  @doc """
  Hello world.
  """
  def from_string(string) do
    collection = %Collection{}
    Parser.generate_collection(collection, string)
  end
end
