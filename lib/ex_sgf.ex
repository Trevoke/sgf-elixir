defmodule ExSgf do
  @moduledoc """
  Documentation for `ExSgf`.
  """

  alias ExSgf.{Collection,GameTree, Parser}

  @doc """
  Hello world.
  """
  def from_string(string) do
    Parser.generate_collection(string)
  end
end
