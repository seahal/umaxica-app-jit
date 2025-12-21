# frozen_string_literal: true

require "test_helper"

class IpOccurrenceTest < ActiveSupport::TestCase
  include OccurrenceTestHelper

  test "public_id presence" do
    record = build_occurrence(IpOccurrence, body: "203.0.113.42", public_id: nil, generate_public_id: false)

    assert_invalid_attribute(record, :public_id)
  end

  test "public_id length" do
    record = build_occurrence(IpOccurrence, body: "203.0.113.42", public_id: "A" * 20)

    assert_invalid_attribute(record, :public_id)
  end

  test "public_id format" do
    record = build_occurrence(IpOccurrence, body: "203.0.113.42", public_id: ("A" * 20) + "!")

    assert_invalid_attribute(record, :public_id)
  end

  test "public_id uniqueness" do
    existing = ip_occurrences(:one)
    record = build_occurrence(IpOccurrence, body: "203.0.113.99", public_id: existing.public_id)

    assert_invalid_attribute(record, :public_id)
  end

  test "body presence" do
    record = build_occurrence(IpOccurrence, body: nil)

    assert_invalid_attribute(record, :body)
  end

  test "body uniqueness" do
    existing = ip_occurrences(:one)
    record = build_occurrence(IpOccurrence, body: existing.body)

    assert_invalid_attribute(record, :body)
  end

  test "status_id presence" do
    record = build_occurrence(IpOccurrence, body: "203.0.113.42", status_id: nil)

    assert_invalid_attribute(record, :status_id)
  end

  test "memo length" do
    record = build_occurrence(IpOccurrence, body: "203.0.113.42", memo: "a" * 1025)

    assert_invalid_attribute(record, :memo)
  end

  test "public_id auto generated on create" do
    record = build_occurrence(IpOccurrence, body: "203.0.113.42", public_id: nil)

    assert_public_id_generated(record)
  end

  test "public_id preserved when provided" do
    custom_public_id = "Z" * 21
    record = build_occurrence(IpOccurrence, body: "203.0.113.42", public_id: custom_public_id)

    assert_public_id_preserved(record, custom_public_id)
  end
end
