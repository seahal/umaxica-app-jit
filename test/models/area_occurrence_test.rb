require "test_helper"

class AreaOccurrenceTest < ActiveSupport::TestCase
  include OccurrenceTestHelper

  test "public_id presence" do
    record = build_occurrence(AreaOccurrence, body: "JP/Tokyo/Shinjuku", public_id: nil, generate_public_id: false)

    assert_invalid_attribute(record, :public_id)
  end

  test "public_id length" do
    record = build_occurrence(AreaOccurrence, body: "JP/Tokyo/Shinjuku", public_id: "A" * 20)

    assert_invalid_attribute(record, :public_id)
  end

  test "public_id format" do
    record = build_occurrence(AreaOccurrence, body: "JP/Tokyo/Shinjuku", public_id: ("A" * 20) + "!")

    assert_invalid_attribute(record, :public_id)
  end

  test "public_id uniqueness" do
    existing = area_occurrences(:one)
    record = build_occurrence(AreaOccurrence, body: "JP/Osaka/Kita", public_id: existing.public_id)

    assert_invalid_attribute(record, :public_id)
  end

  test "body presence" do
    record = build_occurrence(AreaOccurrence, body: nil)

    assert_invalid_attribute(record, :body)
  end

  test "body uniqueness" do
    existing = area_occurrences(:one)
    record = build_occurrence(AreaOccurrence, body: existing.body)

    assert_invalid_attribute(record, :body)
  end

  test "status_id presence" do
    record = build_occurrence(AreaOccurrence, body: "JP/Tokyo/Shinjuku", status_id: nil)

    assert_invalid_attribute(record, :status_id)
  end

  test "memo length" do
    record = build_occurrence(AreaOccurrence, body: "JP/Tokyo/Shinjuku", memo: "a" * 1025)

    assert_invalid_attribute(record, :memo)
  end

  test "public_id auto generated on create" do
    record = build_occurrence(AreaOccurrence, body: "JP/Tokyo/Shinjuku", public_id: nil)

    assert_public_id_generated(record)
  end

  test "public_id preserved when provided" do
    custom_public_id = "Z" * 21
    record = build_occurrence(AreaOccurrence, body: "JP/Tokyo/Shinjuku", public_id: custom_public_id)

    assert_public_id_preserved(record, custom_public_id)
  end

  test "expires_at default" do
    record = build_occurrence(AreaOccurrence, body: "JP/Kyoto/Sakyo", public_id: "Y" * 21)

    assert_expires_at_default(record)
  end
end
