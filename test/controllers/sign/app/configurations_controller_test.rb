# frozen_string_literal: true

require "test_helper"
require "base64"

class Sign::App::ConfigurationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    host! ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
    @user = users(:one)
    @headers = { "X-TEST-CURRENT-USER" => @user.id }.freeze
  end

  test "should get show when logged in" do
    get sign_app_configuration_url(ri: "jp"), headers: @headers

    assert_response :success
    assert_select "a[href^=?]", sign_app_configuration_emails_path(ri: "jp")
    assert_select "a[href^=?]", sign_app_configuration_telephones_path(ri: "jp")
    assert_select "a[href^=?]", sign_app_configuration_google_path(ri: "jp")
    assert_select "a[href^=?]", sign_app_configuration_apple_path(ri: "jp")
    assert_select "a[href^=?]", sign_app_configuration_sessions_path(ri: "jp")
    assert_select "a[href^=?]", sign_app_configuration_withdrawal_path(ri: "jp")
    assert_select "a[href*=?]", edit_sign_app_out_path(ri: "jp"),
                  text: /#{Regexp.escape(I18n.t("sign.app.configuration.show.logout"))}/
    assert_select "a[href*=?]", sign_app_root_path(ri: "jp")
  end

  test "should redirect show when not logged in" do
    get sign_app_configuration_url(ri: "jp")
    assert_response :redirect
    target_path = new_sign_app_in_path
    assert_match %r{#{Regexp.escape(target_path)}\?.*ri=jp}, response.headers["Location"]
  end
end
