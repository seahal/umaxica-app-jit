# frozen_string_literal: true

require "test_helper"

class Sign::App::Configuration::SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    host! ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
    @user = users(:one)
    @host = ENV["SIGN_SERVICE_URL"] || "sign.app.localhost"
    @headers = { "Host" => @host, "X-TEST-CURRENT-USER" => @user.id }.freeze
  end

  test "index returns empty collection" do
    get sign_app_configuration_sessions_url(ri: "jp"), headers: @headers

    assert_response :success
    assert_empty response.parsed_body["sessions"]
  end

  test "lifecycle: create, show, update, destroy" do
    post sign_app_configuration_sessions_url(ri: "jp"), params: { session: { name: "My Session" } }, headers: @headers
    assert_response :created
    created = response.parsed_body.fetch("session")
    assert_equal "My Session", created["name"]

    get sign_app_configuration_session_url(created["id"], ri: "jp"), headers: @headers
    assert_response :success

    patch sign_app_configuration_session_url(created["id"], ri: "jp"),
          params: { session: { status: "revoked" } },
          headers: @headers
    assert_response :success
    assert_equal "revoked", response.parsed_body.dig("session", "status")

    delete sign_app_configuration_session_url(created["id"], ri: "jp"), headers: @headers
    assert_response :see_other

    get sign_app_configuration_session_url(created["id"], ri: "jp"), headers: @headers
    assert_response :not_found
  end

  test "requires authentication" do
    get sign_app_configuration_sessions_url(ri: "jp"), headers: { "Host" => @host }

    assert_response :redirect
  end
end
