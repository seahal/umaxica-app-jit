# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: area_occurrence_statuses
# Database name: occurrence
#
#  id :bigint           not null, primary key
#

require "test_helper"

class AreaOccurrenceStatusTest < ActiveSupport::TestCase
  test "accepts integer ids" do
    record = AreaOccurrenceStatus.new(id: 9)

    assert_predicate record, :valid?
  end

  test "constants are defined" do
    assert_equal 1, AreaOccurrenceStatus::ACTIVE
    assert_equal 2, AreaOccurrenceStatus::NOTHING
  end

  test "has occurrences association" do
    assert_status_association(AreaOccurrenceStatus, :area_occurrences)
  end

  # expires_at column does not exist on area_occurrence_statuses table
  # test "expires_at default" do
  #   record = AreaOccurrenceStatus.new(id: "EXPIRES_AT_TEST")
  #
  #   assert_expires_at_default(record)
  # end
end
