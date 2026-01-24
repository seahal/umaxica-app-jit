# frozen_string_literal: true

require "test_helper"

class UserPasskeyStatusTest < ActiveSupport::TestCase
  fixtures :user_passkey_statuses

  test "upcases id before validation" do
    status = UserPasskeyStatus.new(id: "custom")
    status.valid?
    assert_equal "CUSTOM", status.id
  end
end
