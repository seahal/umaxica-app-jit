# typed: false
# frozen_string_literal: true

require "test_helper"

class Sign::Com::Verification::TotpsControllerTest < ActionDispatch::IntegrationTest
  fixtures :users

  setup do
    @host = ENV.fetch("SIGN_CORPORATE_URL", "sign.com.localhost")
    host! @host
    @user = create_verified_user_with_email(email_address: "com-totp-stepup-#{SecureRandom.hex(4)}@example.com")
    @user.user_telephones.create!(
      number: "+8190#{SecureRandom.random_number(10**8).to_s.rjust(8, "0")}",
      user_telephone_status_id: UserTelephoneStatus::VERIFIED,
    )
    @headers = as_user_headers(@user, host: @host)
  end

  test "new redirects because totp step up is unavailable" do
    get new_sign_com_verification_totp_url(ri: "jp"), headers: @headers

    assert_response :see_other
    assert_redirected_to sign_com_verification_url(ri: "jp")
    assert_equal I18n.t("auth.step_up.method_unavailable"), flash[:alert]
  end

  test "create redirects because totp step up is unavailable" do
    post sign_com_verification_totp_url(ri: "jp"), headers: @headers

    assert_response :see_other
    assert_redirected_to sign_com_verification_url(ri: "jp")
    assert_equal I18n.t("auth.step_up.method_unavailable"), flash[:alert]
  end
end
