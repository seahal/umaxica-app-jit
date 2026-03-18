# typed: false
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
  fixtures :staff_statuses

  test "status constants are defined" do
    assert_equal 1, StaffStatus::ACTIVE
    assert_equal 2, StaffStatus::NOTHING
    assert_equal 3, StaffStatus::RESERVED
  end

  test "status ids are integers" do
    assert_kind_of Integer, StaffStatus::ACTIVE
    assert_kind_of Integer, StaffStatus::NOTHING
    assert_kind_of Integer, StaffStatus::RESERVED
  end

  test "reserved fixture exists" do
    assert_equal StaffStatus::RESERVED, staff_statuses(:reserved).id
  end
end
