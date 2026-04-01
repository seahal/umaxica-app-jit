# typed: false
# frozen_string_literal: true

require "test_helper"
require "base64"

class Core::App::ConfigurationsControllerTest < ActionDispatch::IntegrationTest
  fixtures :users, :user_statuses

  setup do
    host! ENV.fetch("CORE_SERVICE_URL", "ww.app.localhost")
    @user = users(:one)
    @headers = { "X-TEST-CURRENT-USER" => @user.id }.freeze
  end

  test "should get show when logged in" do
    get core_app_configuration_url, headers: @headers

    assert_response :success
  end

  test "should redirect show when not logged in" do
    get core_app_configuration_url(ri: "jp")

    assert_response :redirect
    # First redirect: canonicalize_regional_params removes ri param
    # Second redirect: auth_required redirects to login page
    # Follow the redirect chain
    follow_redirect!

    assert_response :redirect
    target_path = new_sign_app_in_path

    assert_match %r{#{Regexp.escape(target_path)}\?.*rt=}, response.headers["Location"]
  end
end

class Core::Com::ConfigurationsControllerTest < ActionDispatch::IntegrationTest
  fixtures :users, :user_statuses

  setup do
    host! ENV.fetch("CORE_CORPORATE_URL", "ww.com.localhost")
    @user = users(:one)
    @headers = { "X-TEST-CURRENT-USER" => @user.id }.freeze
  end

  test "should get show when logged in" do
    get core_com_configuration_url, headers: @headers

    assert_response :success
  end

  test "should redirect show when not logged in" do
    get core_com_configuration_url(ri: "jp")

    assert_response :redirect
    # First redirect: canonicalize_regional_params removes ri param
    # Second redirect: auth_required redirects to login page
    follow_redirect!

    assert_response :redirect
    target_path = new_sign_app_in_path

    assert_match %r{#{Regexp.escape(target_path)}\?.*rt=}, response.headers["Location"]
  end
end

class Core::Org::ConfigurationsControllerTest < ActionDispatch::IntegrationTest
  fixtures :staffs, :staff_statuses

  setup do
    host! ENV.fetch("CORE_STAFF_URL", "ww.org.localhost")
    @staff = staffs(:one)
    @headers = { "X-TEST-CURRENT-STAFF" => @staff.id }.freeze
  end

  test "should get show when logged in" do
    get core_org_configuration_url, headers: @headers

    assert_response :success
  end

  test "should redirect show when not logged in" do
    get core_org_configuration_url(ri: "jp")

    assert_response :redirect
    # First redirect: canonicalize_regional_params removes ri param
    # Second redirect: auth_required redirects to login page
    follow_redirect!

    assert_response :redirect
    target_path = new_sign_org_in_path

    assert_match %r{#{Regexp.escape(target_path)}\?.*rt=}, response.headers["Location"]
  end
end
