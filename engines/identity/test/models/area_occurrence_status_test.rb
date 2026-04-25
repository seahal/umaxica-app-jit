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
  test "can load nothing status from db" do
    nothing = AreaOccurrenceStatus.find(AreaOccurrenceStatus::NOTHING)

    assert_not_nil nothing
    assert_equal 0, nothing.id
  end

  test "accepts integer ids" do
    record = AreaOccurrenceStatus.new(id: 9)

    assert_predicate record, :valid?
  end

  test "constants are defined" do
    assert_equal 1, AreaOccurrenceStatus::ACTIVE
    assert_equal 0, AreaOccurrenceStatus::NOTHING
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

  test "ensure_defaults! creates missing default records" do
    missing_ids = AreaOccurrenceStatus::DEFAULTS.reject { |id| AreaOccurrenceStatus.exists?(id: id) }
    if missing_ids.any?
      AreaOccurrenceStatus.ensure_defaults!

      missing_ids.each do |id|
        assert AreaOccurrenceStatus.exists?(id: id)
      end
    else
      assert AreaOccurrenceStatus::DEFAULTS.all? { |id| AreaOccurrenceStatus.exists?(id: id) }
    end
  end

  test "ensure_defaults! does nothing when all defaults exist" do
    AreaOccurrenceStatus.ensure_defaults!
    initial_count = AreaOccurrenceStatus.count

    AreaOccurrenceStatus.ensure_defaults!

    assert_equal initial_count, AreaOccurrenceStatus.count
  end
end
