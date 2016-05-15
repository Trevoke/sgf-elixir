defmodule Sgf.StringHelper do

  def find_matching_close_paren(string) do
    String.split(string, "")
    |> Enum.reduce(%{depth: 0, index: 0}, &find_matching_parens/2)
  end

  defp find_matching_parens("(",                    acc), do: %{depth: acc.depth + 1, index: acc.index + 1}
  defp find_matching_parens(")",      %{depth: 0} = acc), do: acc.index
  defp find_matching_parens(")",                    acc), do: %{depth: acc.depth - 1, index: acc.index + 1}
  defp find_matching_parens(_, acc) when is_integer(acc), do: acc
  defp find_matching_parens(_,                      acc), do: %{acc | index: acc.index + 1}
end
