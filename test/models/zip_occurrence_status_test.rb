# frozen_string_literal: true

# == Schema Information
#
# Table name: zip_occurrence_statuses
#
#  id         :string(255)      default("NONE"), not null, primary key
#  expires_at :datetime         not null
#
# Indexes
#
#  index_zip_occurrence_statuses_on_expires_at  (expires_at)
#

require "test_helper"

class ZipOccurrenceStatusTest < ActiveSupport::TestCase
  test "upcases id before validation" do
    assert_upcases_id(ZipOccurrenceStatus)
  end

  test "validates id presence" do
    record = ZipOccurrenceStatus.new(id: nil)

    assert_invalid_attribute(record, :id)
  end

  test "validates id length" do
    record = ZipOccurrenceStatus.new(id: "A" * 256)

    assert_invalid_attribute(record, :id)
  end

  test "validates id format" do
    record = ZipOccurrenceStatus.new(id: "BAD-ID!")

    assert_invalid_attribute(record, :id)
  end

  test "validates id uniqueness case insensitive" do
    record = ZipOccurrenceStatus.new(id: "active")

    assert_invalid_attribute(record, :id)
  end

  test "has occurrences association" do
    assert_status_association(ZipOccurrenceStatus, :zip_occurrences)
  end

  #   test "expires_at default" do
  #     record = ZipOccurrenceStatus.new(id: "EXPIRES_AT_TEST")
  #
  #     assert_expires_at_default(record)
  #   end
end
