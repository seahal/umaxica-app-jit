# frozen_string_literal: true

require "test_helper"
require "base64"

class Core::App::Configuration::EmailsControllerTest < ActionDispatch::IntegrationTest
  setup do
    host! ENV.fetch("CORE_SERVICE_URL", "www.app.localhost")
    @user = users(:one)
    @headers = { "X-TEST-CURRENT-USER" => @user.id }.freeze
  end

  test "should get new when logged in" do
    get new_core_app_configuration_email_url, headers: @headers
    assert_response :success
  end

  test "should redirect new when not logged in" do
    get new_core_app_configuration_email_url(ri: "jp")
    rt = Base64.urlsafe_encode64(new_core_app_configuration_email_url(ri: "jp"))
    assert_redirected_to new_sign_app_in_url(rt: rt, host: "sign.app.localhost")
    assert_equal I18n.t("errors.messages.login_required"), flash[:alert]
  end

  test "should redirect create when not logged in" do
    post core_app_configuration_emails_url(ri: "jp")
    rt = Base64.urlsafe_encode64(core_app_configuration_emails_url(ri: "jp"))
    assert_redirected_to new_sign_app_in_url(rt: rt, host: "sign.app.localhost")
    assert_equal I18n.t("errors.messages.login_required"), flash[:alert]
  end
end

class Core::Org::Configuration::EmailsControllerTest < ActionDispatch::IntegrationTest
  setup do
    host! ENV.fetch("CORE_STAFF_URL", "www.org.localhost")
    @staff = staffs(:one)
    @headers = { "X-TEST-CURRENT-STAFF" => @staff.id }.freeze
  end

  test "should get new when logged in" do
    get new_core_org_configuration_email_url, headers: @headers
    assert_response :success
  end

  test "should redirect new when not logged in" do
    get new_core_org_configuration_email_url(ri: "jp")
    rt = Base64.urlsafe_encode64(new_core_org_configuration_email_url(ri: "jp"))
    assert_redirected_to new_sign_org_in_url(rt: rt, host: "sign.org.localhost")
    assert_equal I18n.t("errors.messages.login_required"), flash[:alert]
  end

  test "should redirect create when not logged in" do
    post core_org_configuration_emails_url(ri: "jp")
    rt = Base64.urlsafe_encode64(core_org_configuration_emails_url(ri: "jp"))
    assert_redirected_to new_sign_org_in_url(rt: rt, host: "sign.org.localhost")
    assert_equal I18n.t("errors.messages.login_required"), flash[:alert]
  end
end
