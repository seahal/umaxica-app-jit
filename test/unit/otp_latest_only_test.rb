# frozen_string_literal: true

require "test_helper"

class OtpLatestOnlyTest < ActiveSupport::TestCase
  class OtpHarness
    include Common::Otp
  end

  test "only the latest OTP succeeds after resend" do
    user = User.create!(status_id: UserStatus::ACTIVE)
    user_email = UserEmail.create!(user: user, address: "latest-only@example.com", user_email_status_id: UserEmailStatus::UNVERIFIED)

    harness = OtpHarness.new

    first_code = harness.generate_otp_for(user_email)
    first_nonce = user_email.reload.otp_nonce

    second_code = harness.generate_otp_for(user_email)
    second_nonce = user_email.reload.otp_nonce

    assert_operator second_nonce, :>, first_nonce

    assert_not harness.verify_otp_code(user_email, first_code)[:success]
    assert harness.verify_otp_code(user_email, second_code)[:success]
  end
end
