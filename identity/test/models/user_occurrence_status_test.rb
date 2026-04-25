# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: user_occurrence_statuses
# Database name: occurrence
#
#  id   :bigint           not null, primary key
#  name :string           default(""), not null
#

require "test_helper"

class UserOccurrenceStatusTest < ActiveSupport::TestCase
  #   test "expires_at default" do
  #     record = UserOccurrenceStatus.new(id: "EXPIRES_AT_TEST")
  #
  #     assert_expires_at_default(record)
  #   end

  test "can load nothing status from db" do
    nothing = UserOccurrenceStatus.find(UserOccurrenceStatus::NOTHING)

    assert_not_nil nothing
    assert_equal 0, nothing.id
  end

  test "accepts integer ids" do
    record = UserOccurrenceStatus.new(id: 9)

    assert_predicate record, :valid?
  end

  test "constants are defined" do
    assert_equal 0, UserOccurrenceStatus::NOTHING
    assert_equal 2, UserOccurrenceStatus::ACTIVE
    assert_equal 3, UserOccurrenceStatus::INACTIVE
    assert_equal 4, UserOccurrenceStatus::DELETED
  end

  test "ensure_defaults! creates missing default records" do
    UserOccurrenceStatus.ensure_defaults!

    UserOccurrenceStatus::DEFAULTS.each do |id|
      assert UserOccurrenceStatus.exists?(id: id)
    end
  end

  test "ensure_defaults! does nothing when all defaults exist" do
    UserOccurrenceStatus.ensure_defaults!
    initial_count = UserOccurrenceStatus.count

    UserOccurrenceStatus.ensure_defaults!

    assert_equal initial_count, UserOccurrenceStatus.count
  end

  test "has occurrences association" do
    assert_status_association(UserOccurrenceStatus, :user_occurrences)
  end
end
