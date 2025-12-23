require "test_helper"

class UserIdentityPasskeyTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @passkey = UserIdentityPasskey.new(
      user: @user,
      webauthn_id: SecureRandom.uuid,
      external_id: SecureRandom.uuid,
      public_key: "test-key",
      description: "My Passkey",
      sign_count: 0
    )
  end

  test "should be valid" do
    assert_predicate @passkey, :valid?
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "should require webauthn_id and public_key" do
    @passkey.webauthn_id = nil

    assert_not @passkey.valid?
    @passkey.webauthn_id = "test-id"

    @passkey.public_key = nil

    assert_not @passkey.valid?
  end

  test "should set default sign_count and description" do
    passkey = UserIdentityPasskey.new(user: @user, webauthn_id: "id2", public_key: "key2")
    passkey.save # trigger callback

    assert_not_nil passkey.external_id
    assert_equal 0, passkey.sign_count
    assert_not_nil passkey.description
  end

  test "should validate uniqueness of webauthn_id" do
    @passkey.save!
    duplicate = @passkey.dup

    assert_not duplicate.valid?
  end

  test "enforces maximum passkeys per user" do
    UserIdentityPasskey::MAX_PASSKEYS_PER_USER.times do |i|
      UserIdentityPasskey.create!(
        user: @user,
        webauthn_id: SecureRandom.uuid,
        external_id: SecureRandom.uuid,
        public_key: "test-key-#{i}",
        description: "Key #{i}"
      )
    end

    extra_passkey = UserIdentityPasskey.new(
      user: @user,
      webauthn_id: SecureRandom.uuid,
      external_id: SecureRandom.uuid,
      public_key: "overflow-key",
      description: "Overflow key"
    )

    assert_not extra_passkey.valid?
    assert_includes extra_passkey.errors[:base], "exceeds maximum passkeys per user (#{UserIdentityPasskey::MAX_PASSKEYS_PER_USER})"
  end
end
