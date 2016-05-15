defmodule StringHelperTest do
  use ExUnit.Case
  alias Sgf.StringHelper

  test "find matching parens" do
    actual = Sgf.StringHelper.find_matching_close_paren "asd)"
    assert 3 == actual
  end

  test "keep track of nested parens" do
    actual = Sgf.StringHelper.find_matching_close_paren "(asd))"
    assert 5 == actual
  end
end
