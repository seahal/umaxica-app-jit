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
end
