# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: telephone_occurrence_statuses
# Database name: occurrence
#
#  id :bigint           not null, primary key
#

require "test_helper"

class TelephoneOccurrenceStatusTest < ActiveSupport::TestCase
  test "can load nothing status from db" do
    nothing = TelephoneOccurrenceStatus.find(TelephoneOccurrenceStatus::NOTHING)

    assert_not_nil nothing
    assert_equal 0, nothing.id
  end

  test "accepts integer ids" do
    record = TelephoneOccurrenceStatus.new(id: 9)

    assert_predicate record, :valid?
  end

  test "constants are defined" do
    assert_equal 1, TelephoneOccurrenceStatus::ACTIVE
    assert_equal 0, TelephoneOccurrenceStatus::NOTHING
  end

  test "has occurrences association" do
    assert_status_association(TelephoneOccurrenceStatus, :telephone_occurrences)
  end

  #   test "expires_at default" do
  #     record = TelephoneOccurrenceStatus.new(id: "EXPIRES_AT_TEST")
  #
  #     assert_expires_at_default(record)
  #   end

  test "ensure_defaults! creates missing default records" do
    TelephoneOccurrenceStatus.ensure_defaults!

    TelephoneOccurrenceStatus::DEFAULTS.each do |id|
      assert TelephoneOccurrenceStatus.exists?(id: id)
    end
  end

  test "ensure_defaults! does nothing when all defaults exist" do
    TelephoneOccurrenceStatus.ensure_defaults!
    initial_count = TelephoneOccurrenceStatus.count

    TelephoneOccurrenceStatus.ensure_defaults!

    assert_equal initial_count, TelephoneOccurrenceStatus.count
  end
end
