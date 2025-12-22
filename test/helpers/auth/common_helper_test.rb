require "test_helper"

class Auth::CommonHelperTest < ActionView::TestCase
  setup do
    extend Auth::CommonHelper
  end

  test "to_localetime converts to JST for jst timezone" do
    test_time = Time.parse("2024-01-01 00:00:00 UTC")

    result = to_localetime(test_time, "jst")

    assert_equal "JST", result.zone
  end

  test "to_localetime converts to UTC by default" do
    test_time = Time.parse("2024-01-01 00:00:00 UTC")

    result = to_localetime(test_time)

    assert_equal "UTC", result.zone
  end

  test "get_timezone returns jst" do
    assert_equal "jst", get_timezone
  end

  test "get_language returns ja" do
    assert_equal "ja", get_language
  end

  test "get_region returns jp" do
    assert_equal "jp", get_region
  end

  test "get_colortheme returns sy" do
    assert_equal "sy", get_colortheme
  end
end
