# frozen_string_literal: true

require "test_helper"

class Api::Com::ApplicationHelperTest < ActionView::TestCase
  setup do
    extend Api::Com::ApplicationHelper
  end

  test "to_localetime should convert time to UTC by default" do
    test_time = Time.parse("2023-12-25 15:30:45 UTC")
    result = to_localetime(test_time)

    assert_equal "UTC", result.zone
    assert_equal test_time.utc, result
  end

  test "to_localetime should convert time to UTC when timezone is explicitly utc" do
    test_time = Time.parse("2023-12-25 15:30:45 UTC")
    result = to_localetime(test_time, "utc")

    assert_equal "UTC", result.zone
    assert_equal test_time.utc, result
  end

  test "to_localetime should convert time to UTC when timezone is uppercase UTC" do
    test_time = Time.parse("2023-12-25 15:30:45 UTC")
    result = to_localetime(test_time, "UTC")

    assert_equal "UTC", result.zone
    assert_equal test_time.utc, result
  end

  test "to_localetime should convert time to JST when timezone is jst" do
    test_time = Time.parse("2023-12-25 15:30:45 UTC")
    result = to_localetime(test_time, "jst")

    assert_equal "JST", result.zone
    assert_equal test_time.in_time_zone("Asia/Tokyo"), result
  end

  test "to_localetime should convert time to JST when timezone is uppercase JST" do
    test_time = Time.parse("2023-12-25 15:30:45 UTC")
    result = to_localetime(test_time, "JST")

    assert_equal "JST", result.zone
    assert_equal test_time.in_time_zone("Asia/Tokyo"), result
  end

  test "to_localetime should handle symbol timezone parameters" do
    test_time = Time.parse("2023-12-25 15:30:45 UTC")

    result_utc = to_localetime(test_time, :utc)

    assert_equal "UTC", result_utc.zone

    result_jst = to_localetime(test_time, :jst)

    assert_equal "JST", result_jst.zone
  end

  test "to_localetime should default to UTC for unknown timezones" do
    test_time = Time.parse("2023-12-25 15:30:45 UTC")
    result = to_localetime(test_time, "unknown_timezone")

    assert_equal "UTC", result.zone
    assert_equal test_time.utc, result
  end

  test "to_localetime should raise exception when time is nil" do
    assert_raises(RuntimeError) do
      to_localetime(nil)
    end
  end

  test "to_localetime should raise exception when time is nil with timezone specified" do
    assert_raises(RuntimeError) do
      to_localetime(nil, "jst")
    end
  end

  test "to_localetime should handle DateTime objects" do
    test_datetime = DateTime.parse("2023-12-25 15:30:45 UTC")
    result = to_localetime(test_datetime, "jst")

    assert_equal "JST", result.zone
  end

  test "to_localetime should handle ActiveSupport::TimeWithZone objects" do
    test_time = Time.current
    result = to_localetime(test_time, "jst")

    assert_equal "JST", result.zone
  end

  test "to_localetime should handle mixed case timezone strings" do
    test_time = Time.parse("2023-12-25 15:30:45 UTC")

    result = to_localetime(test_time, "Jst")

    assert_equal "JST", result.zone

    result2 = to_localetime(test_time, "jSt")

    assert_equal "JST", result2.zone
  end

  test "to_localetime should preserve original time accuracy" do
    test_time = Time.parse("2023-12-25 15:30:45.123456 UTC")
    result = to_localetime(test_time, "jst")

    # Check that microseconds are preserved
    assert_equal test_time.usec, result.utc.usec
  end
end
