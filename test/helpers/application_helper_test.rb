# typed: false
# frozen_string_literal: true

require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  setup do
    extend ApplicationHelper
  end

  def stub_cookie(value)
    define_singleton_method(:cookies) { { "jit_ct" => value } }
  end

  test "theme_cookie_value maps short codes" do
    stub_cookie("dr")

    assert_equal "dark", theme_cookie_value

    stub_cookie("li")

    assert_equal "light", theme_cookie_value

    stub_cookie("sy")

    assert_equal "system", theme_cookie_value
  end

  test "theme_cookie_value accepts full names" do
    stub_cookie("dark")

    assert_equal "dark", theme_cookie_value

    stub_cookie("light")

    assert_equal "light", theme_cookie_value

    stub_cookie("system")

    assert_equal "system", theme_cookie_value
  end

  test "theme_cookie_value falls back to system for unknown values" do
    stub_cookie("unknown")

    assert_equal "system", theme_cookie_value
  end

  test "theme_html_class includes dark class only for dark theme" do
    stub_cookie("dark")

    assert_equal "theme-dark dark", theme_html_class

    stub_cookie("light")

    assert_equal "theme-light", theme_html_class

    stub_cookie("system")

    assert_equal "theme-system", theme_html_class
  end
end
