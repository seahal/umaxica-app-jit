# frozen_string_literal: true

require "test_helper"

class Auth::App::Setting::SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @host = ENV["AUTH_SERVICE_URL"] || "auth.app.localhost"
    @headers = { "Host" => @host, "X-TEST-CURRENT-USER" => @user.id }.freeze
  end

  test "index returns empty collection" do
    get auth_app_setting_sessions_url, headers: @headers

    assert_response :success
    assert_empty response.parsed_body["sessions"]
  end

  test "lifecycle: create, show, update, destroy" do
    post auth_app_setting_sessions_url, params: { session: { name: "My Session" } }, headers: @headers
    assert_response :created
    created = response.parsed_body.fetch("session")
    assert_equal "My Session", created["name"]

    get auth_app_setting_session_url(created["id"]), headers: @headers
    assert_response :success

    patch auth_app_setting_session_url(created["id"]),
          params: { session: { status: "revoked" } },
          headers: @headers
    assert_response :success
    assert_equal "revoked", response.parsed_body.dig("session", "status")

    delete auth_app_setting_session_url(created["id"]), headers: @headers
    assert_response :see_other

    get auth_app_setting_session_url(created["id"]), headers: @headers
    assert_response :not_found
  end

  test "requires authentication" do
    get auth_app_setting_sessions_url, headers: { "Host" => @host }

    assert_response :redirect
  end
end
