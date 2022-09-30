defmodule ExSgf do
  @moduledoc """
  Documentation for `ExSgf`.
  """

  alias ExSgf.{Collection,GameTree, Parser}

  @doc """
  Hello world.
  """
  def from_string(string) do
    Parser.parse_collection(string)
  end
end
