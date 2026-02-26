# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: ip_occurrence_statuses
# Database name: occurrence
#
#  id :bigint           not null, primary key
#

require "test_helper"

class IpOccurrenceStatusTest < ActiveSupport::TestCase
  test "accepts integer ids" do
    record = IpOccurrenceStatus.new(id: 9)

    assert_predicate record, :valid?
  end

  test "constants are defined" do
    assert_equal 1, IpOccurrenceStatus::ACTIVE
    assert_equal 2, IpOccurrenceStatus::NOTHING
  end

  test "has occurrences association" do
    assert_status_association(IpOccurrenceStatus, :ip_occurrences)
  end

  #   test "expires_at default" do
  #     record = IpOccurrenceStatus.new(id: "EXPIRES_AT_TEST")
  #
  #     assert_expires_at_default(record)
  #   end
end
