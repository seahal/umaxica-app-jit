# typed: false
# frozen_string_literal: true

require "test_helper"

class StepUp::AvailableMethodsTest < ActiveSupport::TestCase
  fixtures :users, :staffs

  setup do
    @user = users(:one)
    @staff = staffs(:one)
  end

  test "includes email_otp for verified user email status" do
    @user.user_emails.create!(
      address: "verified-stepup@example.com",
      user_email_status_id: UserEmailStatus::VERIFIED,
    )

    assert_includes StepUp::AvailableMethods.call(@user), :email_otp
  end

  test "does not include email_otp for unverified user email status" do
    @user.user_emails.create!(
      address: "unverified-stepup@example.com",
      user_email_status_id: UserEmailStatus::UNVERIFIED,
    )

    assert_not_includes StepUp::AvailableMethods.call(@user), :email_otp
  end

  test "includes passkey for active passkey status" do
    passkey =
      @user.user_passkeys.new(
        webauthn_id: "stepup_passkey_#{SecureRandom.hex(4)}",
        external_id: SecureRandom.uuid,
        public_key: "public_key",
        sign_count: 0,
        description: "stepup passkey",
        status_id: UserPasskeyStatus::ACTIVE,
      )
    passkey.save!(validate: false)

    assert_includes StepUp::AvailableMethods.call(@user), :passkey
  end

  test "includes totp for active totp status" do
    @user.user_one_time_passwords.create!(
      private_key: ROTP::Base32.random_base32,
      user_one_time_password_status_id: UserOneTimePasswordStatus::ACTIVE,
      last_otp_at: Time.zone.at(0),
    )

    assert_includes StepUp::AvailableMethods.call(@user), :totp
  end

  test "includes email_otp for active staff email status" do
    @staff.staff_emails.create!(
      address: "staff-active-stepup@example.com",
      staff_identity_email_status_id: StaffEmailStatus::ACTIVE,
      otp_counter: "0",
      otp_private_key: "private_key",
    )

    assert_includes StepUp::AvailableMethods.call(@staff), :email_otp
  end

  test "does not include email_otp for inactive staff email status" do
    @staff.staff_emails.create!(
      address: "staff-inactive-stepup@example.com",
      staff_identity_email_status_id: StaffEmailStatus::INACTIVE,
      otp_counter: "0",
      otp_private_key: "private_key",
    )

    assert_not_includes StepUp::AvailableMethods.call(@staff), :email_otp
  end
end
