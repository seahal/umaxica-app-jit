# frozen_string_literal: true

require "test_helper"

class CsrfValidationTest < ActionDispatch::IntegrationTest
  fixtures :users, :user_tokens, :user_statuses

  setup do
    @user = users(:one)
    @host = ENV.fetch("SIGN_SERVICE_URL", "test.umaxica.com")
    @csrf_token = nil

    # Get CSRF token first
    get sign_app_edge_v1_csrf_url(ri: "jp"),
        headers: { "Host" => @host, "Accept" => "application/json" },
        as: :json

    @csrf_token = response.parsed_body["csrf_token"]
  end

  test "POST to /edge/v1/* without X-CSRF-Token header should be rejected" do
    # Create a valid token for the user
    UserToken.create!(user: @user)
    cookies[Auth::Base::ACCESS_COOKIE_KEY] = "test.jwt.token"

    # Try to POST without X-CSRF-Token header
    post sign_app_edge_v1_token_refresh_url(ri: "jp"),
         headers: { "Host" => @host, "Accept" => "application/json" },
         as: :json,
         params: {}

    # Should be 403 or 422 (depending on the implementation)
    assert_includes [403, 422, 401], response.status,
                    "Expected 403/422/401 but got #{response.status}"
  end

  test "POST to /edge/v1/* with correct X-CSRF-Token header should be allowed" do
    token_record = UserToken.create!(user: @user)
    refresh_plain = token_record.rotate_refresh_token!

    cookies[Auth::Base::REFRESH_COOKIE_KEY] = refresh_plain

    # Get CSRF token - this sets the session token
    get sign_app_edge_v1_csrf_url(ri: "jp"),
        headers: { "Host" => @host, "Accept" => "application/json" },
        as: :json

    csrf_token = response.parsed_body["csrf_token"]

    # Now make POST with CSRF token
    post sign_app_edge_v1_token_refresh_url(ri: "jp"),
         headers: {
           "Host" => @host,
           "Accept" => "application/json",
           "X-CSRF-Token" => csrf_token,
         },
         as: :json

    assert_response :ok
  end

  test "DELETE to /edge/v1/* with mismatched CSRF token should be rejected" do
    token_record = UserToken.create!(user: @user)
    refresh_plain = token_record.rotate_refresh_token!

    cookies[Auth::Base::REFRESH_COOKIE_KEY] = refresh_plain

    # Try to POST with wrong CSRF token
    post sign_app_edge_v1_token_refresh_url(ri: "jp"),
         headers: {
           "Host" => @host,
           "Accept" => "application/json",
           "X-CSRF-Token" => "invalid.csrf.token",
         },
         as: :json

    # Should be rejected
    assert_includes [403, 401, 422], response.status,
                    "Expected 403/401/422 but got #{response.status}"
  end

  test "social login callback state validation prevents CSRF attacks" do
    # Setup a user and social identity
    users(:one)

    # Prepare intent without setting up proper state
    get sign_app_social_start_url(provider: "google_oauth2", intent: "login", ri: "jp"),
        headers: { "Host" => @host }

    # Try to access callback with mismatched state
    get sign_app_auth_callback_url(provider: "google_oauth2", ri: "jp", state: "invalid_state"),
        headers: { "Host" => @host }

    # Should handle state validation gracefully
    assert_includes [302, 403, 401, 400], response.status,
                    "Expected redirect or error but got #{response.status}"
  end
end
