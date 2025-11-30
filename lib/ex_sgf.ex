defmodule ExSgf do
  @moduledoc """
  Parse SGF (Smart Game Format) files into navigable tree structures.

  SGF is the standard format for recording Go/Baduk/Weiqi games. This library
  parses SGF strings into a tree that you can navigate using `RoseTree.Zipper`.

  ## Quick Start

      # Parse an SGF string
      sgf = "(;GM[1]SZ[19]PB[Black]PW[White];B[pd];W[dp])"
      {:ok, zipper} = ExSgf.from_string(sgf)

      # Navigate to the game (first child of collection root)
      alias RoseTree.Zipper
      {:ok, game} = Zipper.first_child(zipper)

      # Access game properties
      {tree, _path} = game
      tree.node["PB"]  # => "Black"
      tree.node["SZ"]  # => "19"

      # Navigate to moves
      {:ok, move1} = Zipper.first_child(game)
      {tree, _} = move1
      tree.node["B"]  # => "pd"

  ## Understanding the Output

  `from_string/1` returns a zipper positioned at the **collection root**. An SGF
  file can contain multiple games, so the structure is:

      Collection Root
      └── Game 1 (with game info: PB, PW, SZ, etc.)
          └── Move 1
              └── Move 2
                  ├── Move 3 (main line)
                  └── Move 3 (variation)

  Use `Zipper.first_child/1` to navigate down and `Zipper.next_sibling/1` to
  explore variations.

  ## Common Properties

  - `B`, `W` - Black/White move coordinates (e.g., "pd" = Q16)
  - `PB`, `PW` - Player names
  - `BR`, `WR` - Player ranks
  - `SZ` - Board size
  - `KM` - Komi
  - `RE` - Result (e.g., "B+2.5", "W+Resign")
  - `C` - Comment
  - `AB`, `AW` - Add black/white stones (lists)
  """

  alias ExSgf.Parser.Collection, as: CollectionParser

  @doc """
  Parse an SGF string into a navigable tree.

  Returns `{:ok, zipper}` where the zipper is positioned at the collection root.
  Navigate to individual games using `RoseTree.Zipper.first_child/1`.

  ## Examples

      iex> {:ok, z} = ExSgf.from_string("(;GM[1]PB[Alice]PW[Bob];B[pd])")
      iex> {:ok, game} = RoseTree.Zipper.first_child(z)
      iex> {tree, _} = game
      iex> tree.node["PB"]
      "Alice"

  """
  @spec from_string(binary()) :: {:ok, RoseTree.Zipper.t()}
  def from_string(string) when is_binary(string) do
    CollectionParser.parse(string)
  end
end
