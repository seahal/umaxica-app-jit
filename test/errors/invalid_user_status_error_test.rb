# typed: false
# frozen_string_literal: true

require "test_helper"

class InvalidUserStatusErrorTest < ActiveSupport::TestCase
  def test_invalid_status_is_exposed
    error = InvalidUserStatusError.new(invalid_status: "BANNED")

    assert_equal "BANNED", error.invalid_status
  end

  def test_message_includes_status
    error = InvalidUserStatusError.new(invalid_status: "SUSPENDED", message: "Bad status")

    assert_equal "Bad status: {invalid_status: \"SUSPENDED\"}", error.message
  end

  def test_message_with_i18n_key
    # We need a valid i18n key that exists in the test environment.
    # In this environment, it seems "errors.messages.invalid" translates to Japanese.
    error = InvalidUserStatusError.new(invalid_status: "BANNED", i18n_key: "errors.messages.invalid")

    # Verify it doesn't use the default message
    assert_not_equal "Invalid user status: BANNED", error.message
    # And it contains some content from the translation
    assert_match(/(invalid|不正な値)/i, error.message)
  end
end
