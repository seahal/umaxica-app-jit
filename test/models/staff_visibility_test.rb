# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_visibilities
# Database name: operator
#
#  id :bigint           not null, primary key
#
require "test_helper"

class StaffVisibilityTest < ActiveSupport::TestCase
  fixtures :staff_visibilities, :staffs

  test "has expected fixed ids" do
    assert StaffVisibility.exists?(id: StaffVisibility::NOBODY)
    assert StaffVisibility.exists?(id: StaffVisibility::USER)
    assert StaffVisibility.exists?(id: StaffVisibility::STAFF)
    assert StaffVisibility.exists?(id: StaffVisibility::BOTH)
  end

  test "has many staffs association" do
    assoc = StaffVisibility.reflect_on_association(:staffs)

    assert_not_nil assoc
    assert_equal :has_many, assoc.macro
  end
end
