# typed: false
# frozen_string_literal: true

require "test_helper"
require "base64"

class Core::App::Configuration::EmailsControllerTest < ActionDispatch::IntegrationTest
  fixtures :users, :user_statuses

  setup do
    host! ENV.fetch("MAIN_SERVICE_URL", "main.app.localhost")
    @user = users(:one)
    @headers = { "X-TEST-CURRENT-USER" => @user.id }.freeze
  end

  test "should get new when logged in" do
    get new_main_app_configuration_email_url, headers: @headers

    assert_response :success
  end

  test "should redirect new when not logged in" do
    get new_main_app_configuration_email_url(ri: "jp")

    # First redirect: canonicalize_regional_params removes ri param
    assert_response :redirect
    follow_redirect!

    # Second redirect: auth_required redirects to login
    rt = Base64.urlsafe_encode64(new_main_app_configuration_email_url)

    assert_redirected_to new_sign_app_in_url(rt: rt, host: "sign.app.localhost")
    assert_equal I18n.t("errors.messages.login_required"), flash[:alert]
  end

  test "should redirect create when not logged in" do
    post main_app_configuration_emails_url(ri: "jp")

    # First redirect: canonicalize_regional_params removes ri param
    assert_response :redirect
    follow_redirect!

    # Second redirect: auth_required redirects to login
    # Note: ri is added back via default_url_options
    rt = Base64.urlsafe_encode64(main_app_configuration_emails_url(ri: "jp"))

    assert_redirected_to new_sign_app_in_url(rt: rt, ri: "jp", host: "sign.app.localhost")
  end
end

class Core::Org::Configuration::EmailsControllerTest < ActionDispatch::IntegrationTest
  fixtures :staffs, :staff_statuses

  setup do
    @host = ENV.fetch("MAIN_STAFF_URL", "main.org.localhost")
    @sign_host = ENV.fetch("SIGN_STAFF_URL", "sign.org.localhost")
    host! @host
    @staff = staffs(:one)
    @headers = { "X-TEST-CURRENT-STAFF" => @staff.id }.freeze
  end

  test "should get new when logged in" do
    get new_main_org_configuration_email_url, headers: @headers

    assert_response :success
  end

  test "should redirect new when not logged in" do
    get new_main_org_configuration_email_url(ri: "jp")

    # First redirect: canonicalize_regional_params removes ri param
    assert_response :redirect
    follow_redirect!

    # Second redirect: auth_required redirects to login
    rt = Base64.urlsafe_encode64(new_main_org_configuration_email_url)

    assert_redirected_to new_sign_org_in_url(rt: rt, host: @sign_host)
    assert_equal I18n.t("errors.messages.login_required"), flash[:alert]
  end

  test "should redirect create when not logged in" do
    post main_org_configuration_emails_url(ri: "jp")

    # First redirect: canonicalize_regional_params removes ri param
    assert_response :redirect
    follow_redirect!

    # Second redirect: auth_required redirects to login
    # Note: ri is added back via default_url_options
    rt = Base64.urlsafe_encode64(main_org_configuration_emails_url(ri: "jp"))

    assert_redirected_to new_sign_org_in_url(rt: rt, ri: "jp", host: @sign_host)
  end
end
