require "test_helper"

class StaffWebauthnCredentialTest < ActiveSupport::TestCase
  test "should have authenticator_type enum defined" do
    assert_includes StaffWebauthnCredential.authenticator_types.keys, "platform"
    assert_includes StaffWebauthnCredential.authenticator_types.keys, "roaming"
  end

  test "should have staff association defined" do
    association = StaffWebauthnCredential.reflect_on_association(:staff)

    assert_not_nil association
    assert_equal :belongs_to, association.macro
  end

  test "should inherit from IdentitiesRecord" do
    assert_operator StaffWebauthnCredential, :<, IdentitiesRecord
  end

  test "should be valid with attributes" do
    staff = Staff.new
    staff.save!(validate: false)

    credential = StaffWebauthnCredential.new(
      staff: staff,
      external_id: "test-id-#{SecureRandom.hex}",
      public_key: "key",
      nickname: "my key",
      sign_count: 0
    )

    assert_predicate credential, :valid?
  end

  test "should require external_id and public_key" do
    credential = StaffWebauthnCredential.new

    assert_not credential.valid?
    assert_predicate credential.errors[:external_id], :present?
    assert_predicate credential.errors[:public_key], :present?
  end
end
