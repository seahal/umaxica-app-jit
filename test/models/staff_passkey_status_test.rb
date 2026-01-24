# frozen_string_literal: true

require "test_helper"

class StaffPasskeyStatusTest < ActiveSupport::TestCase
  fixtures :staff_passkey_statuses

  test "upcases id before validation" do
    status = StaffPasskeyStatus.new(id: "custom")
    status.valid?
    assert_equal "CUSTOM", status.id
  end
end
