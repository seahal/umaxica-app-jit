# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_occurrence_statuses
# Database name: occurrence
#
#  id   :bigint           not null, primary key
#  name :string           default(""), not null
#

require "test_helper"

class StaffOccurrenceStatusTest < ActiveSupport::TestCase
  #   test "expires_at default" do
  #     record = StaffOccurrenceStatus.new(id: "EXPIRES_AT_TEST")
  #
  #     assert_expires_at_default(record)
  #   end

  test "accepts integer ids" do
    record = StaffOccurrenceStatus.new(id: 9)
    assert_predicate record, :valid?
  end

  test "constants are defined" do
    assert_equal 1, StaffOccurrenceStatus::NEYO
    assert_equal 2, StaffOccurrenceStatus::ACTIVE
    assert_equal 3, StaffOccurrenceStatus::INACTIVE
    assert_equal 4, StaffOccurrenceStatus::DELETED
  end
end
