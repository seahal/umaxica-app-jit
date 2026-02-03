# frozen_string_literal: true

require "test_helper"
require "base64"

class StepUpAuthenticationTest < ActionDispatch::IntegrationTest
  fixtures :users

  setup do
    @host = ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
    host! @host

    @user = users(:one)
    @token = UserToken.create!(
      user: @user,
      user_token_status_id: UserTokenStatus::NEYO,
      user_token_kind_id: UserTokenKind::BROWSER_WEB,
      public_id: "stepup_#{SecureRandom.hex(5)}",
      refresh_expires_at: 1.day.from_now,
    )
    @token.update!(created_at: 1.hour.ago)

    @headers = {
      "X-TEST-CURRENT-USER" => @user.id.to_s,
      "X-TEST-SESSION-PUBLIC-ID" => @token.public_id,
    }.freeze
  end

  test "GET sensitive page redirects to reauth/new when step-up is not satisfied" do
    get new_sign_app_configuration_email_url(ri: "jp"), headers: @headers

    assert_response :redirect
    uri = URI.parse(response.location)
    query = Rack::Utils.parse_query(uri.query)

    assert_equal new_sign_app_reauth_path, uri.path
    assert_equal "configuration_email", query["scope"]
    assert_equal "jp", query["ri"]
    assert_equal new_sign_app_configuration_email_path(ri: "jp"),
                 Base64.urlsafe_decode64(query["return_to"]).force_encoding("UTF-8")
  end

  test "POST sensitive action redirects to reauth/new when step-up is not satisfied" do
    post sign_app_configuration_emails_url(ri: "jp"),
         params: { user_email: { email: "new@example.com" } },
         headers: @headers

    assert_response :redirect
    uri = URI.parse(response.location)
    query = Rack::Utils.parse_query(uri.query)

    assert_equal new_sign_app_reauth_path, uri.path
    assert_equal "configuration_email", query["scope"]
    assert_equal "jp", query["ri"]
    assert_equal sign_app_configuration_emails_path(ri: "jp"),
                 Base64.urlsafe_decode64(query["return_to"]).force_encoding("UTF-8")
    assert_equal I18n.t("auth.step_up.required"), flash[:alert]
  end

  test "scope mismatch is not satisfied" do
    @token.update!(last_step_up_at: 3.minutes.ago, last_step_up_scope: "withdrawal")

    get sign_app_configuration_emails_url(ri: "jp"), headers: @headers

    assert_response :redirect
    query = Rack::Utils.parse_query(URI.parse(response.location).query)
    assert_equal "configuration_email", query["scope"]
  end

  test "step-up older than 10 minutes is expired" do
    @token.update!(last_step_up_at: 10.minutes.ago, last_step_up_scope: "configuration_email")

    get sign_app_configuration_emails_url(ri: "jp"), headers: @headers

    assert_response :redirect
    assert_equal I18n.t("auth.step_up.required"), flash[:alert]
  end

  test "step-up within TTL and matching scope passes through" do
    @token.update!(last_step_up_at: 5.minutes.ago, last_step_up_scope: "configuration_email")

    get sign_app_configuration_emails_url(ri: "jp"), headers: @headers

    assert_response :success
  end
end
