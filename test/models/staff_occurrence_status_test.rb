# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_occurrence_statuses
# Database name: occurrence
#
#  id :string(255)      default("NEYO"), not null, primary key
#
# Indexes
#
#  index_staff_occurrence_statuses_on_lower_id  (lower((id)::text)) UNIQUE
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
