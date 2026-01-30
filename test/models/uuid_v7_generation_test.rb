# frozen_string_literal: true

require "test_helper"

# PostgreSQL 18+ uuidv7() validation test
# Ensures that UUID primary keys are generated using PostgreSQL's native uuidv7() function
class UuidV7GenerationTest < ActiveSupport::TestCase
  # Test with UserEmail (uuid type primary key)
  test "UserEmail should generate UUIDv7 primary key from database" do
    user = users(:none_user)

    email = UserEmail.create!(
      address: "uuidv7test@example.com",
      user: user,
    )

    assert_predicate email.id, :present?, "ID should be generated"
    assert_uuid_v7 email.id, "UserEmail ID should be UUIDv7"
  end

  # Test with UserPasskey (uuid type primary key)
  test "UserPasskey should generate UUIDv7 primary key from database" do
    user = users(:none_user)

    passkey = UserPasskey.create!(
      user: user,
      webauthn_id: "test_webauthn_id_#{SecureRandom.hex(8)}",
      public_key: "test_public_key",
      sign_count: 0,
    )

    assert_predicate passkey.id, :present?, "ID should be generated"
    assert_uuid_v7 passkey.id, "UserPasskey ID should be UUIDv7"
  end

  # Test time-ordering: UUIDv7 should be time-sortable
  test "UUIDv7 primary keys should be time-ordered" do
    user = users(:none_user)

    # Create two records in sequence
    email1 = UserEmail.create!(
      address: "uuidv7test1@example.com",
      user: user,
    )

    email2 = UserEmail.create!(
      address: "uuidv7test2@example.com",
      user: user,
    )

    # UUIDv7 is time-sortable, so the second ID should be greater than the first
    assert_operator email1.id, :<, email2.id,
                    "Second UUIDv7 should be greater than first (time-ordered)"
  end

  private

  # Validates that a given UUID string is UUIDv7 format
  # UUIDv7 format: xxxxxxxx-xxxx-7xxx-xxxx-xxxxxxxxxxxx
  # The version nibble (first character of 3rd group) must be '7'
  def assert_uuid_v7(uuid_string, message = nil)
    assert_kind_of String, uuid_string, "UUID should be a string"

    # UUIDv7 format: 8-4-4-4-12 hexadecimal characters
    assert_match(
      /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i, uuid_string,
      "UUID should match standard format",
    )

    # Extract version nibble (first character of 3rd group)
    version_nibble = uuid_string.split("-")[2][0]

    assert_equal "7", version_nibble, message || "UUID version nibble should be '7' for UUIDv7"
  end
end
