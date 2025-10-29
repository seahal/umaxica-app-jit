# frozen_string_literal: true

require "test_helper"

class Help::App::ApplicationHelperTest < ActionView::TestCase
  setup do
    extend Help::App::ApplicationHelper
  end

  test "to_localetime converts to UTC by default" do
    test_time = Time.parse("2023-12-25 15:30:45 UTC")
    result = to_localetime(test_time)

    assert_equal "UTC", result.zone
    assert_equal test_time.utc, result
  end

  test "to_localetime converts to UTC when timezone explicitly utc" do
    test_time = Time.parse("2023-12-25 15:30:45 UTC")
    result = to_localetime(test_time, "utc")

    assert_equal "UTC", result.zone
    assert_equal test_time.utc, result
  end

  test "to_localetime converts to JST when timezone jst" do
    test_time = Time.parse("2023-12-25 15:30:45 UTC")
    result = to_localetime(test_time, "jst")

    assert_equal "JST", result.zone
    assert_equal test_time.in_time_zone("Asia/Tokyo"), result
  end

  test "to_localetime defaults to UTC for unknown timezone" do
    test_time = Time.parse("2023-12-25 15:30:45 UTC")
    result = to_localetime(test_time, "unknown_timezone")

    assert_equal "UTC", result.zone
    assert_equal test_time.utc, result
  end

  test "to_localetime accepts symbol timezones" do
    test_time = Time.parse("2023-12-25 15:30:45 UTC")

    assert_equal "UTC", to_localetime(test_time, :utc).zone
    assert_equal "JST", to_localetime(test_time, :jst).zone
  end

  test "to_localetime raises when time is nil" do
    assert_raises(RuntimeError) { to_localetime(nil) }
  end

  test "to_localetime handles DateTime input" do
    test_datetime = DateTime.parse("2023-12-25 15:30:45 UTC")
    result = to_localetime(test_datetime, "jst")

    assert_equal "JST", result.zone
  end

  test "to_localetime handles ActiveSupport::TimeWithZone input" do
    test_time = Time.current
    result = to_localetime(test_time, "jst")

    assert_equal "JST", result.zone
  end

  # Tests for get_title
  test "get_title returns NAME when title blank" do
    original_name = ENV["NAME"]
    original_brand_name = ENV["BRAND_NAME"]
    original_lower = ENV["name"]
    ENV["NAME"] = "TestProduct"
    ENV.delete("BRAND_NAME")
    ENV["name"] = "TestProduct"

    assert_equal "TestProduct", get_title(nil)
    assert_equal "TestProduct", get_title("")
  ensure
    ENV["NAME"] = original_name
    if original_brand_name.nil?
      ENV.delete("BRAND_NAME")
    else
      ENV["BRAND_NAME"] = original_brand_name
    end
    if original_lower.nil?
      ENV.delete("name")
    else
      ENV["name"] = original_lower
    end
  end

  test "get_title concatenates title with NAME when present" do
    original_name = ENV["NAME"]
    original_brand_name = ENV["BRAND_NAME"]
    original_lower = ENV["name"]
    ENV["NAME"] = "TestProduct"
    ENV.delete("BRAND_NAME")
    ENV["name"] = "TestProduct"

    assert_equal "Dashboard | TestProduct", get_title("Dashboard")
  ensure
    ENV["NAME"] = original_name
    if original_brand_name.nil?
      ENV.delete("BRAND_NAME")
    else
      ENV["BRAND_NAME"] = original_brand_name
    end
    if original_lower.nil?
      ENV.delete("name")
    else
      ENV["name"] = original_lower
    end
  end

  test "get_title prefers BRAND_NAME when available" do
    original_name = ENV["NAME"]
    original_brand_name = ENV["BRAND_NAME"]
    original_lower = ENV["name"]
    ENV["NAME"] = "LegacyProduct"
    ENV["BRAND_NAME"] = "NewBrand"
    ENV["name"] = "LegacyProduct"

    assert_equal "NewBrand", get_title(nil)
    assert_equal "Dashboard | NewBrand", get_title("Dashboard")
  ensure
    ENV["NAME"] = original_name
    if original_brand_name.nil?
      ENV.delete("BRAND_NAME")
    else
      ENV["BRAND_NAME"] = original_brand_name
    end
    if original_lower.nil?
      ENV.delete("name")
    else
      ENV["name"] = original_lower
    end
  end

  # Tests for get_timezone
  test "get_timezone returns jst" do
    assert_equal "jst", get_timezone
  end

  # Tests for get_language
  test "get_language returns ja" do
    assert_equal "ja", get_language
  end

  # Tests for get_region
  test "get_region returns jp" do
    assert_equal "jp", get_region
  end

  # Tests for get_colortheme
  test "get_colortheme returns sy" do
    assert_equal "sy", get_colortheme
  end
end
