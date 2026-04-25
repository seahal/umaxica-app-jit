# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: jwt_occurrence_statuses
# Database name: occurrence
#
#  id   :bigint           not null, primary key
#  name :string           default(""), not null
#

require "test_helper"

class JwtOccurrenceStatusTest < ActiveSupport::TestCase
  test "can load nothing status from db" do
    nothing = JwtOccurrenceStatus.find(JwtOccurrenceStatus::NOTHING)

    assert_not_nil nothing
    assert_equal 0, nothing.id
  end

  test "accepts integer ids" do
    record = JwtOccurrenceStatus.new(id: 9)

    assert_predicate record, :valid?
  end

  test "constants are defined" do
    assert_equal 0, JwtOccurrenceStatus::NOTHING
    assert_equal 2, JwtOccurrenceStatus::ACTIVE
    assert_equal 3, JwtOccurrenceStatus::INACTIVE
    assert_equal 4, JwtOccurrenceStatus::DELETED
  end

  test "ensure_defaults! creates missing default records" do
    JwtOccurrenceStatus.ensure_defaults!

    JwtOccurrenceStatus::DEFAULTS.each do |id|
      assert JwtOccurrenceStatus.exists?(id: id)
    end
  end

  test "ensure_defaults! does nothing when all defaults exist" do
    JwtOccurrenceStatus.ensure_defaults!
    initial_count = JwtOccurrenceStatus.count

    JwtOccurrenceStatus.ensure_defaults!

    assert_equal initial_count, JwtOccurrenceStatus.count
  end

  test "has occurrences association" do
    assert_status_association(JwtOccurrenceStatus, :jwt_occurrences)
  end
end
