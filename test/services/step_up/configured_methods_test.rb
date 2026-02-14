# frozen_string_literal: true

require "test_helper"

class StepUp::ConfiguredMethodsTest < ActiveSupport::TestCase
  fixtures :users

  setup do
    @user = users(:one)
  end

  test "includes email_otp for unverified email" do
    @user.user_emails.create!(
      address: "configured-unverified@example.com",
      user_email_status_id: UserEmailStatus::UNVERIFIED,
    )

    assert_includes StepUp::ConfiguredMethods.call(@user), :email_otp
  end
end
