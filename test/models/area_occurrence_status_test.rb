# frozen_string_literal: true

# == Schema Information
#
# Table name: area_occurrence_statuses
# Database name: occurrence
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_area_occurrence_statuses_on_code  (code) UNIQUE
#

require "test_helper"

class AreaOccurrenceStatusTest < ActiveSupport::TestCase
  test "upcases id before validation" do
    assert_upcases_id(AreaOccurrenceStatus)
  end

  test "validates id presence" do
    record = AreaOccurrenceStatus.new(id: nil)

    assert_invalid_attribute(record, :id)
  end

  test "validates id length" do
    record = AreaOccurrenceStatus.new(id: "A" * 256)

    assert_invalid_attribute(record, :id)
  end

  test "validates id format" do
    record = AreaOccurrenceStatus.new(id: "BAD-ID!")

    assert_invalid_attribute(record, :id)
  end

  test "validates id uniqueness case insensitive" do
    record = AreaOccurrenceStatus.new(id: "active")

    assert_invalid_attribute(record, :id)
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
