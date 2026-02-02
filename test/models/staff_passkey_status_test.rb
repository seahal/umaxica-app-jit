# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_passkey_statuses
# Database name: operator
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_staff_passkey_statuses_on_code  (code) UNIQUE
#
require "test_helper"

class StaffPasskeyStatusTest < ActiveSupport::TestCase
  fixtures :staff_passkey_statuses

  test "upcases id before validation" do
    status = StaffPasskeyStatus.new(id: "custom")
    status.valid?
    assert_equal "CUSTOM", status.id
  end
end
