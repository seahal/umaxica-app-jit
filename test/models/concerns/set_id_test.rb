# frozen_string_literal: true

require "test_helper"

# Test with UserEmail which includes SetId
class SetIdTest < ActiveSupport::TestCase
  test "concern can be included in a class" do
    assert_includes UserEmail.included_modules, SetId
  end

  test "should generate UUIDv7 before create" do
    email = UserEmail.new(address: "test@example.com", confirm_policy: true)

    assert_nil email.id
    email.save!

    assert_not_nil email.id
  end

  test "generated id should be UUIDv7 format" do
    email = UserEmail.create!(address: "uuid@example.com", confirm_policy: true)
    # UUID v7 has version bits set to 0111 (7) in the version field
    assert_match(/\A[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\z/i, email.id)
  end

  test "should use SecureRandom.uuid_v7" do
    # Create multiple records and verify they are all valid UUIDs
    3.times do |i|
      email = UserEmail.create!(address: "test#{i}@example.com", confirm_policy: true)

      assert_match(/\A[0-9a-f]{8}-[0-9a-f]{4}-7/, email.id)
    end
  end

  test "should generate different ids for each record" do
    email1 = UserEmail.create!(address: "unique1@example.com", confirm_policy: true)
    email2 = UserEmail.create!(address: "unique2@example.com", confirm_policy: true)

    assert_not_equal email1.id, email2.id
  end

  test "should only generate id before create, not update" do
    email = UserEmail.create!(address: "update@example.com", confirm_policy: true)
    original_id = email.id
    email.update!(address: "updated@example.com")

    assert_equal original_id, email.id
  end
end
