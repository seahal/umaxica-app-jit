# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: zip_occurrence_statuses
# Database name: occurrence
#
#  id :bigint           not null, primary key
#

require "test_helper"

class ZipOccurrenceStatusTest < ActiveSupport::TestCase
  test "can load nothing status from db" do
    nothing = ZipOccurrenceStatus.find(ZipOccurrenceStatus::NOTHING)

    assert_not_nil nothing
    assert_equal 0, nothing.id
  end

  test "accepts integer ids" do
    record = ZipOccurrenceStatus.new(id: 3)

    assert_predicate record, :valid?
  end

  test "has occurrences association" do
    assert_status_association(ZipOccurrenceStatus, :zip_occurrences)
  end

  #   test "expires_at default" do
  #     record = ZipOccurrenceStatus.new(id: "EXPIRES_AT_TEST")
  #
  #     assert_expires_at_default(record)
  #   end

  test "ensure_defaults! creates missing default records" do
    ZipOccurrenceStatus.ensure_defaults!

    ZipOccurrenceStatus::DEFAULTS.each do |id|
      assert ZipOccurrenceStatus.exists?(id: id)
    end
  end

  test "ensure_defaults! does nothing when all defaults exist" do
    ZipOccurrenceStatus.ensure_defaults!
    initial_count = ZipOccurrenceStatus.count

    ZipOccurrenceStatus.ensure_defaults!

    assert_equal initial_count, ZipOccurrenceStatus.count
  end
end
