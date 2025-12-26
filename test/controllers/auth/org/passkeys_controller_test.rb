# frozen_string_literal: true

require "test_helper"

class Auth::Org::PasskeysControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_auth_org_authentication_passkey_url, headers: { "Host" => ENV["AUTH_STAFF_URL"] }

    assert_response :success
  end

  test "should get edit" do
    get edit_auth_org_authentication_passkey_url, headers: { "Host" => ENV["AUTH_STAFF_URL"] }

    assert_response :success
  end

  test "should return ok on create when not logged in" do
    post auth_org_authentication_passkey_url, headers: { "Host" => ENV["AUTH_STAFF_URL"] }

    assert_response :ok
  end

  test "should return ok on update when not logged in" do
    patch auth_org_authentication_passkey_url, headers: { "Host" => ENV["AUTH_STAFF_URL"] }

    assert_response :ok
  end

  test "new authentication passkey page renders Turnstile widget" do
    get new_auth_org_authentication_passkey_url, headers: { "Host" => ENV["AUTH_STAFF_URL"] }

    assert_response :success
    assert_select "div[id^='cf-turnstile-']", count: 1
  end
end
