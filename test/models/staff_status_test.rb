# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_statuses
# Database name: operator
#
#  id :bigint           not null, primary key
#

require "test_helper"

class StaffStatusTest < ActiveSupport::TestCase
  test "status constants are defined" do
    assert_equal 1, StaffStatus::ACTIVE
    assert_equal 2, StaffStatus::NEYO
  end

  test "status ids are integers" do
    assert_kind_of Integer, StaffStatus::ACTIVE
    assert_kind_of Integer, StaffStatus::NEYO
  end
end
