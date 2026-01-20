# frozen_string_literal: true

require "test_helper"
require "base64"

class Core::App::ConfigurationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    host! ENV.fetch("CORE_SERVICE_URL", "www.app.localhost")
    @user = users(:one)
    @headers = { "X-TEST-CURRENT-USER" => @user.id }.freeze
  end

  test "should get show when logged in" do
    get core_app_configuration_url, headers: @headers
    assert_response :success
  end

  test "should redirect show when not logged in" do
    get core_app_configuration_url(ri: "jp")
    rt = Base64.urlsafe_encode64(core_app_configuration_url(ri: "jp"))
    assert_redirected_to new_sign_app_in_url(rt: rt, host: "sign.app.localhost")
  end
end

class Core::Com::ConfigurationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    host! ENV.fetch("CORE_CORPORATE_URL", "www.com.localhost")
    @user = users(:one)
    @headers = { "X-TEST-CURRENT-USER" => @user.id }.freeze
  end

  test "should get show when logged in" do
    get core_com_configuration_url, headers: @headers
    assert_response :success
  end

  test "should redirect show when not logged in" do
    get core_com_configuration_url(ri: "jp")
    rt = Base64.urlsafe_encode64(core_com_configuration_url(ri: "jp"))
    assert_redirected_to new_sign_app_in_url(rt: rt, host: "sign.app.localhost")
  end
end

class Core::Org::ConfigurationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    host! ENV.fetch("CORE_STAFF_URL", "www.org.localhost")
    @staff = staffs(:one)
    @headers = { "X-TEST-CURRENT-STAFF" => @staff.id }.freeze
  end

  test "should get show when logged in" do
    get core_org_configuration_url, headers: @headers
    assert_response :success
  end

  test "should redirect show when not logged in" do
    get core_org_configuration_url(ri: "jp")
    rt = Base64.urlsafe_encode64(core_org_configuration_url(ri: "jp"))
    assert_redirected_to new_sign_org_in_url(rt: rt, host: "sign.org.localhost")
  end
end
