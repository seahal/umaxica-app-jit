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
    ENV["NAME"] = "DocsApp"

    method_arity = method(:title_generator).arity
    blank_result = if method_arity.negative? || method_arity.zero?
                     title_generator
                   else
                     title_generator(nil)
                   end

    assert_equal "DocsApp", blank_result
    assert_equal "DocsApp", title_generator("")
  ensure
    original_name.nil? ? ENV.delete("NAME") : ENV["NAME"] = original_name
  end

  test "title_generator concatenates title with NAME when present" do
    original_name = ENV["NAME"]
    ENV["NAME"] = "DocsApp"

    assert_equal "Guide | DocsApp", title_generator("Guide")
  ensure
    original_name.nil? ? ENV.delete("NAME") : ENV["NAME"] = original_name
  end
end
