# frozen_string_literal: true

require "test_helper"

class Docs::App::ApplicationHelperTest < ActionView::TestCase
  setup do
    extend Docs::App::ApplicationHelper
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
end
