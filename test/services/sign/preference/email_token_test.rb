# typed: false
# frozen_string_literal: true

require "test_helper"

class Sign::Preference::EmailTokenTest < ActiveSupport::TestCase
  test "issue and parse round-trip" do
    token = Sign::Preference::EmailToken.issue(
      email_record_id: 42,
      email_record_type: "UserEmail",
      audience: "app",
    )

    result = Sign::Preference::EmailToken.parse(token, audience: "app")

    assert_not_nil result
    assert_equal 42, result[:email_record_id]
    assert_equal "UserEmail", result[:email_record_type]
  end

  test "parse rejects wrong audience" do
    token = Sign::Preference::EmailToken.issue(
      email_record_id: 1,
      email_record_type: "UserEmail",
      audience: "app",
    )

    result = Sign::Preference::EmailToken.parse(token, audience: "org")

    assert_nil result
  end

  test "parse returns nil for blank token" do
    assert_nil Sign::Preference::EmailToken.parse("", audience: "app")
    assert_nil Sign::Preference::EmailToken.parse(nil, audience: "app")
  end

  test "parse returns nil for tampered token" do
    assert_nil Sign::Preference::EmailToken.parse("tampered-garbage", audience: "app")
  end

  test "token expires after TTL" do
    token = Sign::Preference::EmailToken.issue(
      email_record_id: 1,
      email_record_type: "UserEmail",
      audience: "app",
    )

    travel 3.hours do
      result = Sign::Preference::EmailToken.parse(token, audience: "app")
      assert_nil result
    end
  end
end
