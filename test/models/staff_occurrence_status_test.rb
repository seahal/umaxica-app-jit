# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_occurrence_statuses
# Database name: occurrence
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_staff_occurrence_statuses_on_code  (code) UNIQUE
#

require "test_helper"

class StaffOccurrenceStatusTest < ActiveSupport::TestCase
  #   test "expires_at default" do
  #     record = StaffOccurrenceStatus.new(id: "EXPIRES_AT_TEST")
  #
  #     assert_expires_at_default(record)
  #   end

  test "validates length of id" do
    record = StaffOccurrenceStatus.new(id: "A" * 256)
    assert_predicate record, :invalid?
    assert_predicate record.errors[:id], :any?
  end
end
