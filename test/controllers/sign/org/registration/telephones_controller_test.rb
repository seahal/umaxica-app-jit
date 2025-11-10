require "test_helper"

class Sign::Org::Registration::TelephonesControllerTest < ActionDispatch::IntegrationTest
  test "new renders successfully" do
    get new_sign_org_registration_telephone_url, headers: default_headers

    assert_response :success
  end

  test "create sends otp to submitted telephone number" do
    number = "+819012345678"
    delivered_to = nil

    SmsService.stub :send_message, ->(**kwargs) { delivered_to = kwargs[:to] } do
      post sign_org_registration_telephones_url,
           params: telephone_params(number),
           headers: default_headers
    end

    assert_response :redirect
    assert_equal number, delivered_to
  end

  test "update redirects back to new when session data is missing" do
    patch sign_org_registration_telephone_url("missing"),
          params: { user_telephone: { pass_code: "123456" } },
          headers: default_headers

    assert_redirected_to new_sign_org_registration_telephone_url(lx: "ja", ri: "jp", tz: "jst")
    assert_equal I18n.t("sign.org.registration.telephone.edit.your_session_was_expired"), flash[:notice]
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "update succeeds with valid pending registration session" do
    otp_code = nil
    SmsService.stub :send_message, ->(**kwargs) { otp_code = extract_otp(kwargs[:message]); true } do
      post sign_org_registration_telephones_url,
           params: telephone_params("+814512345678"),
           headers: default_headers
    end

    registration_id = response.location[%r{/registration/telephones/([^/]+)/edit}, 1]

    assert_predicate registration_id, :present?, "registration id should be present in redirect location"
    assert_predicate otp_code, :present?, "otp code should be captured from sms message"

    patch sign_org_registration_telephone_url(registration_id),
          params: { user_telephone: { pass_code: otp_code } },
          headers: default_headers

    assert_redirected_to "/"
    assert_equal I18n.t("sign.org.registration.telephone.update.success"), flash[:notice]
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "update rejects invalid otp code" do
    otp_code = nil
    SmsService.stub :send_message, ->(**kwargs) { otp_code = extract_otp(kwargs[:message]); true } do
      post sign_org_registration_telephones_url,
           params: telephone_params("+819055566666"),
           headers: default_headers
    end

    registration_id = response.location[%r{/registration/telephones/([^/]+)/edit}, 1]

    assert_predicate registration_id, :present?, "registration id should be present in redirect location"
    assert_predicate otp_code, :present?, "otp code should be captured from sms message"

    wrong_code = otp_code.tr("0123456789", "1234567890")

    patch sign_org_registration_telephone_url(registration_id),
          params: { user_telephone: { pass_code: wrong_code } },
          headers: default_headers

    assert_response :unprocessable_content
  end

  private

  def telephone_params(number)
    { user_telephone: { number: number, confirm_policy: "1", confirm_using_mfa: "1" } }
  end

  def default_headers
    { "Host" => host }
  end

  def host
    ENV["SIGN_STAFF_URL"] || "sign.org.localhost"
  end

  def extract_otp(message)
    message.to_s[/PassCode => (\d+)/, 1]
  end
end
