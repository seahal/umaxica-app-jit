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
  test "can load nothing status from db" do
    nothing = EmailOccurrenceStatus.find(EmailOccurrenceStatus::NOTHING)

    assert_not_nil nothing
    assert_equal 0, nothing.id
  end

  test "accepts integer ids" do
    record = EmailOccurrenceStatus.new(id: 9)

    assert_predicate record, :valid?
  end

  test "constants are defined" do
    assert_equal 1, EmailOccurrenceStatus::ACTIVE
    assert_equal 0, EmailOccurrenceStatus::NOTHING
  end

  test "has occurrences association" do
    assert_status_association(EmailOccurrenceStatus, :email_occurrences)
  end

  #   test "expires_at default" do
  #     record = EmailOccurrenceStatus.new(id: "EXPIRES_AT_TEST")
  #
  #     assert_expires_at_default(record)
  #   end

  test "ensure_defaults! creates missing default records" do
    EmailOccurrenceStatus.ensure_defaults!

    EmailOccurrenceStatus::DEFAULTS.each do |id|
      assert EmailOccurrenceStatus.exists?(id: id)
    end
  end

  test "ensure_defaults! does nothing when all defaults exist" do
    EmailOccurrenceStatus.ensure_defaults!
    initial_count = EmailOccurrenceStatus.count

    EmailOccurrenceStatus.ensure_defaults!

    assert_equal initial_count, EmailOccurrenceStatus.count
  end
end
