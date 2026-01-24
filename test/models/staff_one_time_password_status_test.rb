# frozen_string_literal: true

require "test_helper"

class StaffOneTimePasswordStatusTest < ActiveSupport::TestCase
  fixtures :staff_one_time_password_statuses

  test "upcases id before validation" do
    status = StaffOneTimePasswordStatus.new(id: "custom")
    status.valid?
    assert_equal "CUSTOM", status.id
  end
end
