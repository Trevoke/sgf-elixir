defmodule ExSgf.SiblingVariationsTest do
  use ExUnit.Case, async: true

  alias RoseTree.Zipper, as: Z

  describe "sibling variations after nested branches" do
    test "parses sibling variations when first sibling contains nested branches" do
      # This mimics the structure in the Shusaku-Shuwa SGF:
      # After move 3 (W[gc]), there are TWO sibling variations for move 4:
      # - B[gd] (main variation with nested sub-variations)
      # - B[ee] (alternative variation)
      sgf = """
      (;SZ[19]PB[Black]PW[White]
      ;W[cd];B[ec];W[gc]
      (;B[gd];W[hd];B[fd]
        (;W[cg];B[hc])
        (;W[ic];B[cf])
      )
      (;B[ee];W[df]))
      """

      {:ok, zipper} = ExSgf.from_string(sgf)
      {:ok, game_zipper} = Z.first_child(zipper)

      # Navigate to move 3 (W[gc])
      {:ok, z1} = Z.first_child(game_zipper)  # W[cd]
      {:ok, z2} = Z.first_child(z1)           # B[ec]
      {:ok, z3} = Z.first_child(z2)           # W[gc]

      {tree3, _} = z3

      # W[gc] should have 2 children: B[gd] and B[ee]
      assert length(tree3.children) == 2,
        "Move 3 (W[gc]) should have 2 children, but has #{length(tree3.children)}"

      # Verify the children are the correct moves
      [child1, child2] = tree3.children
      assert Map.get(child1.node, "B") == "gd", "First child should be B[gd]"
      assert Map.get(child2.node, "B") == "ee", "Second child should be B[ee]"
    end

    test "parses sibling variations when first sibling is very deep" do
      # Even more extreme: first variation goes very deep, second is short
      # This more closely mimics the actual Shusaku-Shuwa structure
      deep_moves = 1..10 |> Enum.map(fn i ->
        color = if rem(i, 2) == 1, do: "W", else: "B"
        coord = <<(?a + rem(i, 19)), (?a + rem(i + 3, 19))>>
        ";#{color}[#{coord}]"
      end) |> Enum.join("")

      sgf = """
      (;SZ[19]
      ;W[cd];B[ec];W[gc]
      (;B[gd]#{deep_moves}
        (;W[aa];B[bb])
        (;W[cc];B[dd])
      )
      (;B[ee];W[df]))
      """

      {:ok, zipper} = ExSgf.from_string(sgf)
      {:ok, game_zipper} = Z.first_child(zipper)

      # Navigate to move 3 (W[gc])
      {:ok, z1} = Z.first_child(game_zipper)  # W[cd]
      {:ok, z2} = Z.first_child(z1)           # B[ec]
      {:ok, z3} = Z.first_child(z2)           # W[gc]

      {tree3, _} = z3

      # W[gc] should have 2 children: B[gd] and B[ee]
      assert length(tree3.children) == 2,
        "Move 3 (W[gc]) should have 2 children even when first is deep, but has #{length(tree3.children)}"
    end

    test "parses the actual Shusaku-Shuwa SGF structure" do
      # Load the actual file if available, or use a representative excerpt
      sgf_path = Path.join([__DIR__, "..", "..", "tcik-ash", "test", "fixtures", "1840-05-12-Shusaku-Shuwa.sgf"])

      if File.exists?(sgf_path) do
        sgf_content = File.read!(sgf_path)
        {:ok, zipper} = ExSgf.from_string(sgf_content)
        {:ok, game_zipper} = Z.first_child(zipper)

        # Navigate to move 3 (W[gc])
        {:ok, z1} = Z.first_child(game_zipper)  # W[cd]
        {:ok, z2} = Z.first_child(z1)           # B[ec]
        {:ok, z3} = Z.first_child(z2)           # W[gc]

        {tree3, _} = z3
        assert Map.get(tree3.node, "W") == "gc", "Should be at W[gc]"

        # The actual Shusaku-Shuwa file has 2 variations at move 4:
        # B[gd] (main) and B[ee] (alternative)
        assert length(tree3.children) >= 2,
          "Move 3 (W[gc]) should have at least 2 children (B[gd] and B[ee]), but has #{length(tree3.children)}"
      else
        # Skip if file not available
        IO.puts("Skipping Shusaku-Shuwa test - file not found at #{sgf_path}")
      end
    end
  end
end
