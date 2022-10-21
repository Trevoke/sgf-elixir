defmodule ExSgf.PropertiesTest do
  use ExUnit.Case, async: true

  alias ExSgf.Accumulator, as: A
  alias ExSgf.Parser.Properties, as: PropertiesParser

  describe "property identities" do
    test "continues until it finds an open bracket" do
      chunk = "AB["
      expected = {"AB", "["}
      actual = PropertiesParser.parse_identity(chunk, %A{})
      assert expected == actual
    end
  end

  describe "property values" do
    test "continues until there is a closing bracket" do
      chunk = "[foobarbaz]"
      expected = {["foobarbaz"], ""}
      actual = PropertiesParser.parse_value(chunk, %A{property_value: [], value_status: :closed})
      assert expected == actual
    end

    test "continues while there is an opening bracket after a closing bracket" do
      chunk = "[foobarbaz][foobarqux]"
      expected = {["foobarbaz", "foobarqux"], ""}
      actual = PropertiesParser.parse_value(chunk, %A{property_value: [], value_status: :closed})
      assert expected == actual
    end

    test "reads multiple values on multiple lines" do
      chunk = "[foobarbaz]\n[foobarqux]"
      expected = {["foobarbaz", "foobarqux"], ""}
      actual = PropertiesParser.parse_value(chunk, %A{property_value: [], value_status: :closed})
      assert expected == actual
    end

    test "treat an escaped closing bracket as part of the value" do
      chunk = "[foobar\\]baz]"
      expected = {["foobar\\]baz"], ""}
      actual = PropertiesParser.parse_value(chunk, %A{property_value: [], value_status: :closed})
      assert expected == actual
    end
  end

  describe "properties" do
    test "list identities have list values" do
      chunk = "AW[cc][cd];"
      expected = {%{"AW" => ["cd", "cc"]}, ";"}
      actual = PropertiesParser.parse(chunk, %A{})
      assert expected == actual
    end

    test "non-list identities have single values" do
      chunk = "W[cc];"
      expected = {%{"W" => "cc"}, ";"}
      actual = PropertiesParser.parse(chunk, %A{})
      assert expected == actual
    end
  end

end