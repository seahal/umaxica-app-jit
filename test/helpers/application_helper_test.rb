# typed: false
# frozen_string_literal: true

require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  include ActiveSupport::Testing::TimeHelpers

  fixtures :app_banners, :org_banners, :com_banners, :users, :user_statuses, :staffs, :staff_statuses

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

  test "current_banner_for returns current banner for each surface" do
    travel_to Time.zone.parse("2026-03-18 00:00:00 UTC") do
      assert_equal app_banners(:newer_current_app_banner), current_banner_for(:app)
      assert_equal org_banners(:current_org_banner), current_banner_for(:org)
      assert_equal com_banners(:current_com_banner), current_banner_for(:com)
    end
  end

  test "render_current_banner renders current banner partial" do
    travel_to Time.zone.parse("2026-03-18 00:00:00 UTC") do
      rendered_banner = render_current_banner(:app)

      assert_includes rendered_banner, "App newer banner"
      assert_includes rendered_banner, "App newer banner body"
    end
  end

  test "render_current_banner returns nothing when current banner is missing" do
    ComBanner.stub :current, ComBanner.none do
      rendered_banner = render_current_banner(:com)

      assert_nil rendered_banner
    end
  end
end
