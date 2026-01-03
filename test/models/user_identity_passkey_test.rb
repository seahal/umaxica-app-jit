# frozen_string_literal: true

# == Schema Information
#
# Table name: user_identity_passkeys
#
#  id                              :uuid             not null, primary key
#  created_at                      :datetime         not null
#  description                     :string           default(""), not null
#  external_id                     :uuid             not null
#  public_key                      :text             not null
#  sign_count                      :integer          default(0), not null
#  updated_at                      :datetime         not null
#  user_id                         :uuid             not null
#  user_identity_passkey_status_id :string(255)      default("ACTIVE"), not null
#  webauthn_id                     :string           default(""), not null
#
# Indexes
#
#  idx_on_user_identity_passkey_status_id_f979a7d699  (user_identity_passkey_status_id)
#  index_user_identity_passkeys_on_user_id            (user_id)
#  index_user_identity_passkeys_on_webauthn_id        (webauthn_id) UNIQUE
#

require "test_helper"

class UserIdentityPasskeyTest < ActiveSupport::TestCase
  def setup
    @user = User.find_by!(public_id: "one_id")
    @passkey = UserIdentityPasskey.new(
      user: @user,
      webauthn_id: SecureRandom.uuid,
      external_id: SecureRandom.uuid,
      public_key: "test-key",
      description: "My Passkey",
      sign_count: 0,
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
        description: "Key #{i}",
      )
    end

    extra_passkey = UserIdentityPasskey.new(
      user: @user,
      webauthn_id: SecureRandom.uuid,
      external_id: SecureRandom.uuid,
      public_key: "overflow-key",
      description: "Overflow key",
    )

    assert_not extra_passkey.valid?
    assert_includes extra_passkey.errors[:base], "exceeds maximum passkeys per user (#{UserIdentityPasskey::MAX_PASSKEYS_PER_USER})"
  end

  test "description is invalid when blank" do
    @passkey.description = ""
    @passkey.define_singleton_method(:set_defaults) { } # Skip callback to test validation
    assert_not @passkey.valid?
    assert_not_empty @passkey.errors[:description]
  end

  test "sign_count cannot be negative" do
    @passkey.sign_count = -1
    assert_not @passkey.valid?
    assert_not_empty @passkey.errors[:sign_count]
  end

  test "association deletion: destroys when user is destroyed" do
    @passkey.save!
    @user.destroy
    assert_raise(ActiveRecord::RecordNotFound) { @passkey.reload }
  end
end
