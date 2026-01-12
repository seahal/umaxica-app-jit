# frozen_string_literal: true

require "test_helper"

class Sign::App::ConfigurationsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get sign_app_configuration_url(ri: "jp"), headers: { "Host" => @host }

    assert_response :success
    assert_select "a[href^=?]", sign_app_configuration_emails_path(ri: "jp")
    assert_select "a[href^=?]", sign_app_configuration_telephones_path(ri: "jp")
    assert_select "a[href^=?]", sign_app_configuration_google_path(ri: "jp")
    assert_select "a[href^=?]", sign_app_configuration_apple_path(ri: "jp")
    assert_select "a[href^=?]", sign_app_configuration_sessions_path(ri: "jp")
    assert_select "a[href^=?]", sign_app_configuration_withdrawal_path(ri: "jp")
    assert_select "a[href*=?]", sign_app_root_path(ri: "jp"), text: I18n.t("sign.app.configuration.show.back")
  end
end
