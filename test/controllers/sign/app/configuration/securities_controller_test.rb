# frozen_string_literal: true

require "test_helper"

class Sign::App::Configuration::SecuritiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    host! ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
    @host = ENV["SIGN_SERVICE_URL"] || "sign.app.localhost"
    @user = users(:one)
    @headers = { "Host" => @host, "X-TEST-CURRENT-USER" => @user.id }.freeze
  end

  test "requires authentication" do
    get edit_sign_app_configuration_security_url(ri: "jp")

    assert_response :redirect
  end

  test "renders dashboard" do
    get edit_sign_app_configuration_security_url(ri: "jp"), headers: @headers

    assert_response :success
    assert_select "h1", text: I18n.t("controller.sign.app.configuration.security.edit.title")
  end

  test "update refreshes review timestamp" do
    patch sign_app_configuration_security_url(ri: "jp"), headers: @headers

    assert_response :redirect
    assert_redirected_to edit_sign_app_configuration_security_path(ri: "jp")
    assert_match I18n.t("controller.sign.app.configuration.security.update.success"), flash[:notice]
    assert_not_nil session[:sign_app_configuration_security_reviewed_at]
  end
end
