require "test_helper"

class StaffWebauthnCredentialTest < ActiveSupport::TestCase
  # Tests that don't require database tables

  test "should have authenticator_type enum defined" do
    # Test enum values without database access
    assert_includes StaffWebauthnCredential.authenticator_types.keys, "platform"
    assert_includes StaffWebauthnCredential.authenticator_types.keys, "roaming"
  end

  test "should have active scope defined" do
    assert_respond_to StaffWebauthnCredential, :active
  end

  test "should have staff association defined" do
    association = StaffWebauthnCredential.reflect_on_association(:staff)
    assert_not_nil association
    assert_equal :belongs_to, association.macro
  end

  test "should have increment_sign_count method defined" do
    assert StaffWebauthnCredential.method_defined?(:increment_sign_count!)
  end

  test "should have deactivate method defined" do
    assert StaffWebauthnCredential.method_defined?(:deactivate!)
  end

  test "should inherit from IdentifiersRecord" do
    assert StaffWebauthnCredential < IdentifiersRecord
  end
end
