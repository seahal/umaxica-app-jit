require "test_helper"

class UserWebauthnCredentialTest < ActiveSupport::TestCase
  # Tests that don't require database tables

  test "should have authenticator_type enum defined" do
    # Test enum values without database access
    assert_includes UserWebauthnCredential.authenticator_types.keys, "platform"
    assert_includes UserWebauthnCredential.authenticator_types.keys, "roaming"
  end

  test "should have active scope defined" do
    assert_respond_to UserWebauthnCredential, :active
  end

  test "should have user association defined" do
    association = UserWebauthnCredential.reflect_on_association(:user)
    assert_not_nil association
    assert_equal :belongs_to, association.macro
  end

  test "should have increment_sign_count method defined" do
    assert UserWebauthnCredential.method_defined?(:increment_sign_count!)
  end

  test "should have deactivate method defined" do
    assert UserWebauthnCredential.method_defined?(:deactivate!)
  end

  test "should inherit from IdentifiersRecord" do
    assert UserWebauthnCredential < IdentifiersRecord
  end
end
