# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: email_occurrence_statuses
# Database name: occurrence
#
#  id :bigint           not null, primary key
#

require "test_helper"

class EmailOccurrenceStatusTest < ActiveSupport::TestCase
  test "accepts integer ids" do
    record = EmailOccurrenceStatus.new(id: 9)

    assert_predicate record, :valid?
  end

  test "constants are defined" do
    assert_equal 1, EmailOccurrenceStatus::ACTIVE
    assert_equal 2, EmailOccurrenceStatus::NEYO
  end

  test "has occurrences association" do
    assert_status_association(EmailOccurrenceStatus, :email_occurrences)
  end

  #   test "expires_at default" do
  #     record = EmailOccurrenceStatus.new(id: "EXPIRES_AT_TEST")
  #
  #     assert_expires_at_default(record)
  #   end
end
