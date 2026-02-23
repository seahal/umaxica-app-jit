# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: domain_occurrence_statuses
# Database name: occurrence
#
#  id :bigint           not null, primary key
#

require "test_helper"

class DomainOccurrenceStatusTest < ActiveSupport::TestCase
  test "accepts integer ids" do
    record = DomainOccurrenceStatus.new(id: 9)
    assert_predicate record, :valid?
  end

  test "constants are defined" do
    assert_equal 1, DomainOccurrenceStatus::ACTIVE
    assert_equal 2, DomainOccurrenceStatus::DELETED
    assert_equal 3, DomainOccurrenceStatus::INACTIVE
    assert_equal 4, DomainOccurrenceStatus::NEYO
    assert_equal 5, DomainOccurrenceStatus::PENDING
  end

  test "has occurrences association" do
    assert_status_association(DomainOccurrenceStatus, :domain_occurrences)
  end

  #   test "expires_at default" do
  #     record = DomainOccurrenceStatus.new(id: "EXPIRES_AT_TEST")
  #
  #     assert_expires_at_default(record)
  #   end
end
