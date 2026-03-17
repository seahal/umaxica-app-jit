# typed: false
# frozen_string_literal: true

require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  setup do
    extend ApplicationHelper
  end

  def stub_cookie(value)
    define_singleton_method(:cookies) { { "ct" => value } }
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

  test "page_title sets content for with title" do
    view.extend(ApplicationHelper)
    view.content_for(:page_title, nil)

    view.page_title("Test Title")

    assert_equal "Test Title", view.content_for(:page_title)
  end

  test "page_title returns translation default when no title set" do
    view.extend(ApplicationHelper)

    result = view.page_title

    expected = I18n.t("meta.default_title", default: "")

    assert_equal expected, result
  end

  test "theme_class is backward compatible alias for theme_html_class" do
    stub_cookie("dark")

    assert_equal theme_html_class, theme_class
  end
end
