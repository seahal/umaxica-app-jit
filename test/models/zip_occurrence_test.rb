# frozen_string_literal: true

# == Schema Information
#
# Table name: zip_occurrences
#
#  id         :uuid             not null, primary key
#  public_id  :string(21)       default(""), not null
#  body       :string(16)       default(""), not null
#  status_id  :string(255)      default("NEYO"), not null
#  memo       :string(1024)     default(""), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  expires_at :datetime         not null
#
# Indexes
#
#  index_zip_occurrences_on_body        (body) UNIQUE
#  index_zip_occurrences_on_expires_at  (expires_at)
#  index_zip_occurrences_on_public_id   (public_id) UNIQUE
#  index_zip_occurrences_on_status_id   (status_id)
#

require "test_helper"

class ZipOccurrenceTest < ActiveSupport::TestCase
  test "public_id length" do
    record = build_occurrence(ZipOccurrence, body: "1500001", public_id: "A" * 20)

    assert_invalid_attribute(record, :public_id)
  end

  test "public_id format" do
    record = build_occurrence(ZipOccurrence, body: "1500001", public_id: ("A" * 20) + "!")

    assert_invalid_attribute(record, :public_id)
  end

  test "public_id uniqueness" do
    existing = zip_occurrences(:one)
    record = build_occurrence(ZipOccurrence, body: "1600001", public_id: existing.public_id)

    assert_invalid_attribute(record, :public_id)
  end

  test "body presence" do
    record = build_occurrence(ZipOccurrence, body: nil)

    assert_invalid_attribute(record, :body)
  end

  test "body uniqueness" do
    existing = zip_occurrences(:one)
    record = build_occurrence(ZipOccurrence, body: existing.body)

    assert_invalid_attribute(record, :body)
  end

  test "status_id presence" do
    record = build_occurrence(ZipOccurrence, body: "1500001", status_id: nil)

    assert_invalid_attribute(record, :status_id)
  end

  test "memo length" do
    record = build_occurrence(ZipOccurrence, body: "1500001", memo: "a" * 1025)

    assert_invalid_attribute(record, :memo)
  end

  test "public_id auto generated on create" do
    record = build_occurrence(ZipOccurrence, body: "1500001", public_id: nil)

    assert_public_id_generated(record)
  end

  test "public_id preserved when provided" do
    custom_public_id = "Z" * 21
    record = build_occurrence(ZipOccurrence, body: "1500001", public_id: custom_public_id)

    assert_public_id_preserved(record, custom_public_id)
  end

  test "expires_at default" do
    record = build_occurrence(ZipOccurrence, body: "1700001", public_id: "Y" * 21)

    assert_expires_at_default(record)
  end
end
