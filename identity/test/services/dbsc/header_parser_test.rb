# typed: false
# frozen_string_literal: true

require "test_helper"

class Dbsc::HeaderParserTest < ActiveSupport::TestCase
  test "string_value returns nil for blank string" do
    assert_nil Dbsc::HeaderParser.string_value("")
    assert_nil Dbsc::HeaderParser.string_value("   ")
  end

  test "string_value strips whitespace" do
    assert_equal "hello", Dbsc::HeaderParser.string_value("  hello  ")
  end

  test "string_value removes surrounding quotes" do
    assert_equal "hello", Dbsc::HeaderParser.string_value('"hello"')
    assert_equal "hello world", Dbsc::HeaderParser.string_value('"hello world"')
  end

  test "string_value returns unquoted strings as-is" do
    assert_equal "hello", Dbsc::HeaderParser.string_value("hello")
  end
end
