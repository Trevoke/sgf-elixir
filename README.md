# ExSgf

Parse and navigate Go game records in Elixir.

SGF (Smart Game Format) is the standard file format for Go/Baduk/Weiqi games. ExSgf turns SGF files into a navigable tree structure, so you can extract game information, replay moves, and explore variations programmatically.

**For:** Developers building Go-related applications, game analysis tools, or working with game record databases.

## Your First Parse in 60 Seconds

```elixir
# Add to mix.exs: {:ex_sgf, "~> 0.4.0"}

# Parse an SGF string
sgf = "(;GM[1]SZ[19]PB[Lee Sedol]PW[AlphaGo];B[pd];W[dp];B[cd])"
{:ok, zipper} = ExSgf.from_string(sgf)

# Get the game node (first child of root)
alias RoseTree.Zipper
{:ok, game} = Zipper.first_child(zipper)

# Read game info
{tree, _path} = game
tree.node["PB"]  # => "Lee Sedol"
tree.node["PW"]  # => "AlphaGo"
tree.node["SZ"]  # => "19"

# Get first move
{:ok, move1} = Zipper.first_child(game)
{tree, _} = move1
tree.node["B"]  # => "pd" (Black plays at Q16)
```

That's it. You've parsed an SGF and extracted data from it.

## Installation

Add `ex_sgf` to your dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_sgf, "~> 0.4.0"}
  ]
end
```

## Understanding SGF Structure

Before diving deeper, let's understand what you're working with.

### SGF is a Tree, Not a List

A Go game isn't just a sequence of moves. Players often record **variations**—alternative lines of play they considered. This creates a tree structure:

```
         Move 1 (B plays)
            │
         Move 2 (W plays)
            │
    ┌───────┴───────┐
    │               │
 Move 3          Move 3 (variation)
 (main line)     (what if W played here instead?)
    │               │
 Move 4          Move 4
```

In SGF format, this looks like:

```
(;GM[1]          <- Game info
  ;B[pd]         <- Move 1
  ;W[dp]         <- Move 2
  (;B[cd]        <- Move 3, main line
    ;W[qp])         Move 4
  (;B[pp]        <- Move 3, variation
    ;W[dd]))        Move 4
```

ExSgf parses this into a tree you can navigate.

### The Zipper: Your Cursor in the Tree

ExSgf gives you a **zipper**—think of it as a cursor that tracks where you are in the tree. You can:

- Move down to children (next moves)
- Move up to parents (previous moves)
- Move sideways to siblings (alternative variations)
- Always know your current position

```elixir
# You're at move 3, main line
# Want to see the variation? Go up, then to the sibling

{:ok, parent} = Zipper.ascend(current)           # Back to move 2
{:ok, variation} = Zipper.next_sibling(parent)   # The variation branch
```

## Tutorial: Extract Game Information

Most SGF files start with metadata about the game. Here's how to extract it:

```elixir
sgf = File.read!("game.sgf")
{:ok, zipper} = ExSgf.from_string(sgf)

# Game info is in the first node of the game tree
{:ok, game} = RoseTree.Zipper.first_child(zipper)
{tree, _path} = game
info = tree.node

# Common properties
info["PB"]  # Black player name
info["PW"]  # White player name
info["BR"]  # Black rank
info["WR"]  # White rank
info["DT"]  # Date
info["RE"]  # Result (e.g., "B+2.5", "W+Resign")
info["KM"]  # Komi
info["SZ"]  # Board size
info["HA"]  # Handicap
```

### Making it Convenient

```elixir
defmodule GameInfo do
  alias RoseTree.Zipper

  def extract(sgf_string) do
    {:ok, zipper} = ExSgf.from_string(sgf_string)
    {:ok, game} = Zipper.first_child(zipper)
    {tree, _} = game

    %{
      black: tree.node["PB"],
      white: tree.node["PW"],
      result: tree.node["RE"],
      date: tree.node["DT"],
      board_size: String.to_integer(tree.node["SZ"] || "19")
    }
  end
end

GameInfo.extract(sgf)
# => %{black: "Lee Sedol", white: "AlphaGo", result: "W+Resign", ...}
```

## Tutorial: Replay a Game Move by Move

Let's walk through all moves in the main line:

```elixir
alias RoseTree.Zipper

defmodule GameReplay do
  def main_line(sgf_string) do
    {:ok, zipper} = ExSgf.from_string(sgf_string)
    {:ok, game} = Zipper.first_child(zipper)

    collect_moves(game, [])
  end

  defp collect_moves(zipper, moves) do
    {tree, _path} = zipper

    # Extract move from this node (if any)
    move = case {tree.node["B"], tree.node["W"]} do
      {coord, nil} when coord != nil -> {:black, coord}
      {nil, coord} when coord != nil -> {:white, coord}
      _ -> nil
    end

    moves = if move, do: moves ++ [move], else: moves

    # Try to go to next move (first child)
    case Zipper.first_child(zipper) do
      {:ok, next} -> collect_moves(next, moves)
      :error -> moves
    end
  end
end

GameReplay.main_line(sgf)
# => [{:black, "pd"}, {:white, "dp"}, {:black, "cd"}, {:white, "qp"}, ...]
```

### Understanding Coordinates

SGF uses letter coordinates: `a`=1, `b`=2, ... `s`=19. The coordinate `"pd"` means column `p` (16), row `d` (4)—or Q16 in standard notation.

```elixir
def sgf_to_coord(sgf_coord) do
  <<col, row>> = sgf_coord
  {col - ?a + 1, row - ?a + 1}
end

sgf_to_coord("pd")  # => {16, 4}
```

## Tutorial: Navigate Variations

Professional game records often include variations—alternative moves with commentary. Here's how to find and explore them:

```elixir
alias RoseTree.Zipper

def has_variations?(zipper) do
  {tree, _path} = zipper
  length(tree.children) > 1
end

def get_variations(zipper) do
  {tree, _path} = zipper

  tree.children
  |> Enum.with_index()
  |> Enum.map(fn {child, index} ->
    %{
      index: index,
      move: child.node["B"] || child.node["W"],
      comment: child.node["C"],
      is_main: index == 0
    }
  end)
end
```

### Walking a Variation

```elixir
# At a node with variations, get the second variation (index 1)
{:ok, first_child} = Zipper.first_child(zipper)
{:ok, second_variation} = Zipper.next_sibling(first_child)

# Now continue down this variation
{:ok, next_move} = Zipper.first_child(second_variation)
```

### Example: Find All Commented Positions

```elixir
def find_comments(zipper, acc \\ []) do
  {tree, _path} = zipper

  acc = case tree.node["C"] do
    nil -> acc
    comment -> [{get_move(tree.node), comment} | acc]
  end

  # Visit all children
  case Zipper.first_child(zipper) do
    {:ok, child} ->
      acc = find_comments(child, acc)
      visit_siblings(child, acc)
    :error ->
      acc
  end
end

defp visit_siblings(zipper, acc) do
  case Zipper.next_sibling(zipper) do
    {:ok, sibling} ->
      acc = find_comments(sibling, acc)
      visit_siblings(sibling, acc)
    :error ->
      acc
  end
end

defp get_move(node) do
  node["B"] || node["W"] || "root"
end
```

## Common Patterns

### Pattern: Count Total Moves

```elixir
def count_moves(zipper, count \\ 0) do
  {tree, _path} = zipper
  count = if tree.node["B"] || tree.node["W"], do: count + 1, else: count

  case RoseTree.Zipper.first_child(zipper) do
    {:ok, child} -> count_moves(child, count)
    :error -> count
  end
end
```

### Pattern: Get Move Number N

```elixir
def get_move_at(zipper, n, current \\ 0)
def get_move_at(zipper, n, current) when current == n do
  {tree, _path} = zipper
  {:ok, tree.node}
end
def get_move_at(zipper, n, current) do
  case RoseTree.Zipper.first_child(zipper) do
    {:ok, child} -> get_move_at(child, n, current + 1)
    :error -> :error
  end
end
```

### Pattern: Parse Multiple Games

Some SGF files contain multiple games (game collections). ExSgf handles these—each game becomes a child of the root:

```elixir
{:ok, zipper} = ExSgf.from_string(multi_game_sgf)

# Root's children are individual games
{tree, _path} = zipper
game_count = length(tree.children)

# Get second game
{:ok, first_game} = Zipper.first_child(zipper)
{:ok, second_game} = Zipper.next_sibling(first_game)
```

## API Reference

### ExSgf

| Function | Type | Description |
|----------|------|-------------|
| `from_string/1` | `binary() -> {:ok, Zipper.t()}` | Parse SGF string into navigable tree |

### RoseTree.Zipper Navigation

| Function | Description |
|----------|-------------|
| `first_child/1` | Move to first child node |
| `last_child/1` | Move to last child node |
| `next_sibling/1` | Move to next sibling (variation) |
| `prev_sibling/1` | Move to previous sibling |
| `ascend/1` | Move to parent node |
| `to_root/1` | Move to tree root |
| `to_tree/1` | Extract RoseTree from zipper |

All navigation functions return `{:ok, zipper}` or `:error`.

### Accessing Node Data

```elixir
{tree, _path} = zipper
tree.node           # Map of SGF properties for this node
tree.children       # List of child RoseTree nodes
```

### Common SGF Properties

| Property | Description | Example |
|----------|-------------|---------|
| `B` | Black move | `"pd"` |
| `W` | White move | `"dp"` |
| `C` | Comment | `"Good move!"` |
| `PB` | Black player | `"Lee Sedol"` |
| `PW` | White player | `"AlphaGo"` |
| `BR` | Black rank | `"9p"` |
| `WR` | White rank | `"9d"` |
| `DT` | Date | `"2016-03-09"` |
| `RE` | Result | `"W+Resign"` |
| `KM` | Komi | `"7.5"` |
| `SZ` | Board size | `"19"` |
| `HA` | Handicap | `"2"` |
| `AB` | Add black stones | `["pd", "dp"]` |
| `AW` | Add white stones | `["dd", "pp"]` |
| `LB` | Labels | `["pd:A", "dp:B"]` |
| `TR` | Triangle marks | `["pd", "dp"]` |
| `CR` | Circle marks | `["dd"]` |
| `SQ` | Square marks | `["pp"]` |
| `MA` | X marks | `["qq"]` |

## License

MIT License. See [LICENSE](LICENSE) for details.
