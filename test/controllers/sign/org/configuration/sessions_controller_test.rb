# frozen_string_literal: true

require "test_helper"

class Sign::Org::Configuration::SessionsControllerTest < ActionDispatch::IntegrationTest
  fixtures :staffs, :staff_statuses

  setup do
    host! ENV.fetch("SIGN_STAFF_URL", "sign.org.localhost")
    @staff = staffs(:one)
    @host = ENV["SIGN_STAFF_URL"] || "sign.org.localhost"
    @headers = { "Host" => @host, "X-TEST-CURRENT-STAFF" => @staff.id }.freeze
  end

  test "index returns empty collection" do
    get sign_org_configuration_sessions_url(ri: "jp"), headers: @headers

    assert_response :success
    assert_empty response.parsed_body["sessions"]
  end

  test "lifecycle: create, show, update, destroy" do
    post sign_org_configuration_sessions_url(ri: "jp"), params: { session: { name: "Org Session" } }, headers: @headers
    assert_response :created
    created = response.parsed_body.fetch("session")

    get sign_org_configuration_session_url(created["id"], ri: "jp"), headers: @headers
    assert_response :success

    patch sign_org_configuration_session_url(created["id"], ri: "jp"),
          params: { session: { status: "revoked" } },
          headers: @headers
    assert_response :success
    assert_equal "revoked", response.parsed_body.dig("session", "status")

    delete sign_org_configuration_session_url(created["id"], ri: "jp"), headers: @headers
    assert_response :see_other

    get sign_org_configuration_session_url(created["id"], ri: "jp"), headers: @headers
    assert_response :not_found
  end

  test "requires authentication" do
    get sign_org_configuration_sessions_url(ri: "jp"), headers: { "Host" => @host }

    assert_response :redirect
  end
end
