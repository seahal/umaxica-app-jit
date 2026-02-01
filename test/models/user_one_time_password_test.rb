# frozen_string_literal: true

# == Schema Information
#
# Table name: user_one_time_passwords
# Database name: principal
#
#  id                                        :bigint           not null, primary key
#  last_otp_at                               :datetime         default(-Infinity), not null
#  private_key                               :string(1024)     default(""), not null
#  title                                     :string(32)
#  created_at                                :datetime         not null
#  updated_at                                :datetime         not null
#  public_id                                 :string(21)
#  user_id                                   :bigint           not null
#  user_identity_one_time_password_status_id :integer          default(0), not null
#
# Indexes
#
#  idx_on_user_identity_one_time_password_status_id_c03cdf0b39  (user_identity_one_time_password_status_id)
#  index_user_one_time_passwords_on_public_id                   (public_id) UNIQUE
#  index_user_one_time_passwords_on_user_id                     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#  fk_rails_...  (user_identity_one_time_password_status_id => user_one_time_password_statuses.id)
#

require "test_helper"

class UserOneTimePasswordTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(public_id: "u_#{SecureRandom.hex(8)}", status_id: "NEYO")
    @status = UserOneTimePasswordStatus.find("ACTIVE")
    # Ensure NEYO status exists for defaults
    unless UserOneTimePasswordStatus.exists?("NEYO")
      UserOneTimePasswordStatus.create!(id: "NEYO")
    end

    @private_key = "test-secret-key-12345"
    @last_otp_at = Time.current
  end

  test "inherits from PrincipalRecord" do
    assert_operator UserOneTimePassword, :<, PrincipalRecord
  end

  test "belongs to user" do
    association = UserOneTimePassword.reflect_on_association(:user)

    assert_not_nil association
    assert_equal :belongs_to, association.macro
  end

  test "belongs to user_one_time_password_status" do
    association = UserOneTimePassword.reflect_on_association(:user_one_time_password_status)

    assert_not_nil association
    assert_equal :belongs_to, association.macro
  end

  test "has private_key attribute" do
    record = UserOneTimePassword.new(
      user: @user,
      private_key: @private_key,
      last_otp_at: @last_otp_at,
    )

    assert_equal @private_key, record.private_key
  end

  test "has last_otp_at attribute" do
    record = UserOneTimePassword.new(
      user: @user,
      private_key: @private_key,
      last_otp_at: @last_otp_at,
    )

    # Compare timestamps ignoring nanosecond precision
    assert_in_delta @last_otp_at, record.last_otp_at, 1.second
  end

  test "auto-generates private_key if blank" do
    record = UserOneTimePassword.new(
      user: @user,
      last_otp_at: @last_otp_at,
    )

    # Private key should be generated automatically
    assert_not_nil record.private_key
    assert_predicate record, :valid?
  end

  test "validates presence of last_otp_at" do
    record = UserOneTimePassword.new(
      user: @user,
      private_key: @private_key,
      last_otp_at: nil,
    )

    assert_not record.valid?
    assert_not_empty record.errors[:last_otp_at]
  end

  test "validates private_key length maximum" do
    record = UserOneTimePassword.new(
      user: @user,
      private_key: "x" * 1025,
      last_otp_at: @last_otp_at,
    )

    assert_not record.valid?
    assert_not_empty record.errors[:private_key]
  end

  test "enforces maximum totp records per user" do
    new_user = User.create!(
      status_id: "NEYO",
    )

    UserOneTimePassword::MAX_TOTPS_PER_USER.times do
      UserOneTimePassword.create!(
        user: new_user,
        private_key: ROTP::Base32.random_base32,
        last_otp_at: Time.current,
      )
    end

    extra_totp = UserOneTimePassword.new(
      user: new_user,
      private_key: ROTP::Base32.random_base32,
      last_otp_at: Time.current,
    )

    assert_not extra_totp.valid?
    assert_includes extra_totp.errors[:base], "exceeds maximum totps per user (#{UserOneTimePassword::MAX_TOTPS_PER_USER})"
  end

  test "association deletion: destroys when user is destroyed" do
    record = UserOneTimePassword.create!(user: @user)
    @user.destroy
    assert_raise(ActiveRecord::RecordNotFound) { record.reload }
  end
end
