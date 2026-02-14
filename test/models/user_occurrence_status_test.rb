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

  test "accepts integer ids" do
    record = UserOccurrenceStatus.new(id: 9)
    assert_predicate record, :valid?
  end

  test "constants are defined" do
    assert_equal 1, UserOccurrenceStatus::NEYO
    assert_equal 2, UserOccurrenceStatus::ACTIVE
    assert_equal 3, UserOccurrenceStatus::INACTIVE
    assert_equal 4, UserOccurrenceStatus::DELETED
  end
end
