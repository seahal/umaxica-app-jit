# frozen_string_literal: true

require "test_helper"

class Auth::Org::AuthenticationsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_auth_org_authentication_url, headers: { "Host" => ENV["AUTH_STAFF_URL"] }

    assert_response :success
  end

  test "renders turnstile widget" do
    get new_auth_org_authentication_url, headers: { "Host" => ENV["AUTH_STAFF_URL"] }

    assert_response :success
    assert_select "div[id^='cf-turnstile-']", count: 1
  end

  test "renders authentication links" do
    get new_auth_org_authentication_url, headers: { "Host" => ENV["AUTH_STAFF_URL"] }

    assert_response :success

    query = { lx: "ja", ri: "jp", tz: "jst", ct: "sy" }
    assert_select "a[href=?]", new_auth_org_authentication_passkey_path(query)
    assert_select "a[href=?]", new_auth_org_authentication_recovery_path(query)
  end

  test "should respond to destroy action" do
    # Test that the controller has a destroy action
    assert_includes Auth::Org::AuthenticationsController.instance_methods, :destroy
  end
end
