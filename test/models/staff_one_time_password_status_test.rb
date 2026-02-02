# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_one_time_password_statuses
# Database name: operator
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_staff_one_time_password_statuses_on_code  (code) UNIQUE
#
require "test_helper"

class StaffOneTimePasswordStatusTest < ActiveSupport::TestCase
  fixtures :staff_one_time_password_statuses

  test "upcases id before validation" do
    status = StaffOneTimePasswordStatus.new(id: "custom")
    status.valid?
    assert_equal "CUSTOM", status.id
  end
end
