# frozen_string_literal: true

require "test_helper"

require "ostruct"

class Sign::App::Configuration::EmailsControllerTest < ActionDispatch::IntegrationTest
  setup do
    host! ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
    @host = ENV["SIGN_SERVICE_URL"] || "sign.app.localhost"
    @user = users(:one)
    @email = OpenStruct.new(id: "1")
  end

  def request_headers
    { "Host" => @host, "X-TEST-CURRENT-USER" => @user.id }
  end

  test "should get index" do
    get sign_app_configuration_emails_url(ri: "jp"), headers: request_headers
    assert_response :success
  end

  test "should get new" do
    get new_sign_app_configuration_email_url(ri: "jp"), headers: request_headers
    assert_response :success
  end

  test "should redirect index when not logged in" do
    get sign_app_configuration_emails_url(ri: "jp")
    rt = Base64.urlsafe_encode64(sign_app_configuration_emails_url(ri: "jp"))
    assert_redirected_to new_sign_app_in_url(rt: rt, host: "sign.app.localhost")
    assert_equal I18n.t("errors.messages.login_required"), flash[:alert]
  end
end
