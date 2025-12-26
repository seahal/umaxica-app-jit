# frozen_string_literal: true

# == Schema Information
#
# Table name: domain_occurrence_statuses
#
#  id         :string(255)      default("NONE"), not null, primary key
#  expires_at :datetime         not null
#
# Indexes
#
#  index_domain_occurrence_statuses_on_expires_at  (expires_at)
#

require "test_helper"

class DomainOccurrenceStatusTest < ActiveSupport::TestCase
  include OccurrenceStatusTestHelper

  test "upcases id before validation" do
    assert_upcases_id(DomainOccurrenceStatus)
  end

  test "validates id presence" do
    record = DomainOccurrenceStatus.new(id: nil)

    assert_invalid_attribute(record, :id)
  end

  test "validates id length" do
    record = DomainOccurrenceStatus.new(id: "A" * 256)

    assert_invalid_attribute(record, :id)
  end

  test "validates id format" do
    record = DomainOccurrenceStatus.new(id: "BAD-ID!")

    assert_invalid_attribute(record, :id)
  end

  test "validates id uniqueness case insensitive" do
    record = DomainOccurrenceStatus.new(id: "active")

    assert_invalid_attribute(record, :id)
  end

  test "has occurrences association" do
    assert_status_association(DomainOccurrenceStatus, :domain_occurrences)
  end

  test "expires_at default" do
    record = DomainOccurrenceStatus.new(id: "EXPIRES_AT_TEST")

    assert_expires_at_default(record)
  end
end
