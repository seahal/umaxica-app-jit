# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_one_time_password_statuses
# Database name: operator
#
#  id         :string           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
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
