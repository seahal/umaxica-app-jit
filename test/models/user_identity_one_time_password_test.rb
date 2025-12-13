# == Schema Information
#
# Table name: user_identity_one_time_passwords
#
#  user_id                              :binary           not null
#  user_identity_one_time_password_status_id :string
#  private_key                          :string(1024)
#  last_otp_at                          :datetime
#  created_at                           :datetime         not null
#  updated_at                           :datetime         not null
#
require "test_helper"

class UserIdentityOneTimePasswordTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @status = user_identity_one_time_password_statuses(:active)
    @private_key = "test-secret-key-12345"
    @last_otp_at = Time.current
  end

  test "inherits from IdentitiesRecord" do
    assert_operator UserIdentityOneTimePassword, :<, IdentitiesRecord
  end

  test "belongs to user" do
    association = UserIdentityOneTimePassword.reflect_on_association(:user)

    assert_not_nil association
    assert_equal :belongs_to, association.macro
  end

  test "belongs to user_identity_one_time_password_status" do
    association = UserIdentityOneTimePassword.reflect_on_association(:user_identity_one_time_password_status)

    assert_not_nil association
    assert_equal :belongs_to, association.macro
  end

  test "has private_key attribute" do
    record = UserIdentityOneTimePassword.new(
      user: @user,
      private_key: @private_key,
      last_otp_at: @last_otp_at
    )

    assert_equal @private_key, record.private_key
  end

  test "has last_otp_at attribute" do
    record = UserIdentityOneTimePassword.new(
      user: @user,
      private_key: @private_key,
      last_otp_at: @last_otp_at
    )

    # Compare timestamps ignoring nanosecond precision
    assert_in_delta @last_otp_at, record.last_otp_at, 1.second
  end

  test "auto-generates private_key if blank" do
    record = UserIdentityOneTimePassword.new(
      user: @user,
      last_otp_at: @last_otp_at
    )

    # Private key should be generated automatically
    assert_not_nil record.private_key
    assert_predicate record, :valid?
  end

  test "validates presence of last_otp_at" do
    record = UserIdentityOneTimePassword.new(
      user: @user,
      private_key: @private_key
    )

    assert_not record.valid?
    assert_not_empty record.errors[:last_otp_at]
  end

  test "validates private_key length maximum" do
    record = UserIdentityOneTimePassword.new(
      user: @user,
      private_key: "x" * 1025,
      last_otp_at: @last_otp_at
    )

    assert_not record.valid?
    assert_not_empty record.errors[:private_key]
  end
end
