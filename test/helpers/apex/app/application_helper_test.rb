# frozen_string_literal: true

require "test_helper"

class Apex::App::ApplicationHelperTest < ActionView::TestCase
  setup do
    extend Apex::App::ApplicationHelper
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

  test "title_generator returns NAME when title blank" do
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

  test "title_generator concatenates title with NAME when present" do
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

  test "show true timezone" do
    assert_equal "jst", get_timezone
  end

  test "show false timezone" do
    assert_not_equal get_timezone, "kst"
  end

  # Tests for get_timezone parameter/session handling
  test "get_timezone returns param value when present" do
    params[:tz] = "utc"

    assert_equal "utc", get_timezone
  end

  test "get_timezone returns session value when param absent" do
    session[:lx] = "custom_tz"

    assert_equal "custom_tz", get_timezone
  end

  test "get_timezone prefers param over session" do
    params[:tz] = "param_tz"
    session[:lx] = "session_tz"

    assert_equal "param_tz", get_timezone
  end

  # Tests for get_language
  test "get_language returns param value when present" do
    params[:lx] = "en"

    assert_equal "en", get_language
  end

  test "get_language returns session value when param absent" do
    session[:lx] = "zh"

    assert_equal "zh", get_language
  end

  test "get_language returns default ja when no param or session" do
    assert_equal "ja", get_language
  end

  test "get_language prefers param over session" do
    params[:lx] = "en"
    session[:lx] = "zh"

    assert_equal "en", get_language
  end

  # Tests for get_region
  test "get_region returns param value when present" do
    params[:ri] = "us"

    assert_equal "us", get_region
  end

  test "get_region returns session value when param absent" do
    session[:ri] = "cn"

    assert_equal "cn", get_region
  end

  test "get_region returns default jp when no param or session" do
    assert_equal "jp", get_region
  end

  test "get_region prefers param over session" do
    params[:ri] = "us"
    session[:ri] = "cn"

    assert_equal "us", get_region
  end

  # Tests for get_colortheme
  test "get_colortheme returns param value when present" do
    params[:ct] = "dark"

    assert_equal "dark", get_colortheme
  end

  test "get_colortheme returns session value when param absent" do
    session[:ct] = "light"

    assert_equal "light", get_colortheme
  end

  test "get_colortheme returns default sy when no param or session" do
    assert_equal "sy", get_colortheme
  end

  test "get_colortheme prefers param over session" do
    params[:ct] = "dark"
    session[:ct] = "light"

    assert_equal "dark", get_colortheme
  end

  test "title_generator prefers BRAND_NAME when available" do
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
end
