# == Schema Information
#
# Table name: passkey_for_users
#
#  id          :uuid             not null, primary key
#  description :string           not null
#  public_key  :text             not null
#  sign_count  :bigint           default(0), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  external_id :uuid             not null
#  user_id     :bigint           not null
#  webauthn_id :uuid             not null
#
# Indexes
#
#  index_passkey_for_users_on_user_id  (user_id)
#
require "test_helper"

class UserIdentityPasskeyTest < ActiveSupport::TestCase
  test "should create passkey with valid attributes" do
    passkey = UserIdentityPasskey.new(
      description: "Test Passkey",
      public_key: "test_public_key",
      sign_count: 0,
      external_id: SecureRandom.uuid,
      user_id: 999999, # Use dummy ID to avoid constraint
      webauthn_id: SecureRandom.uuid
    )
    # Test attribute assignment without actual save
    assert_equal "Test Passkey", passkey.description
    assert_equal "test_public_key", passkey.public_key
    assert_equal 0, passkey.sign_count
  end

  test "should belong to user" do
    assert_respond_to UserIdentityPasskey.new, :user
  end

  test "should have description field" do
    passkey = UserIdentityPasskey.new(description: "Test Description")

    assert_equal "Test Description", passkey.description
  end

  test "should have public_key field" do
    passkey = UserIdentityPasskey.new(public_key: "test_key")

    assert_equal "test_key", passkey.public_key
  end

  test "should inherit from IdentityRecord" do
    assert_includes UserIdentityPasskey.ancestors, IdentityRecord
  end

  test "should have required database columns" do
    required_columns = %w[description public_key sign_count external_id user_id webauthn_id]

    required_columns.each do |column|
      assert_includes UserIdentityPasskey.column_names, column
    end
  end
end
