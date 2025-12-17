require "test_helper"

class UserWebauthnCredentialTest < ActiveSupport::TestCase
  test "should have authenticator_type enum defined" do
    assert_includes UserWebauthnCredential.authenticator_types.keys, "platform"
    assert_includes UserWebauthnCredential.authenticator_types.keys, "roaming"
  end

  test "should have user association defined" do
    association = UserWebauthnCredential.reflect_on_association(:user)

    assert_not_nil association
    assert_equal :belongs_to, association.macro
  end

  test "should inherit from IdentitiesRecord" do
    assert_operator UserWebauthnCredential, :<, IdentitiesRecord
  end

  test "should be valid with attributes" do
    user = User.new
    user.save!(validate: false)

    credential = UserWebauthnCredential.new(
      user: user,
      external_id: "test-id-#{SecureRandom.hex}",
      public_key: "key",
      nickname: "my key",
      sign_count: 0
    )

    assert_predicate credential, :valid?
  end

  test "should require external_id and public_key" do
    credential = UserWebauthnCredential.new

    assert_not credential.valid?
    assert_predicate credential.errors[:external_id], :present?
    assert_predicate credential.errors[:public_key], :present?
  end

  test "should increment sign count" do
    user = User.new
    user.save!(validate: false)
    credential = UserWebauthnCredential.create!(
      user: user,
      external_id: "test-id-#{SecureRandom.hex}",
      public_key: "key",
      nickname: "my key",
      sign_count: 0
    )

    assert_difference -> { credential.reload.sign_count }, 1 do
      credential.increment_sign_count!
    end
  end
end
