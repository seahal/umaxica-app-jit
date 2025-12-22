require "test_helper"

class Auth::Org::Setting::SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @staff = staffs(:one)
    @host = ENV["AUTH_STAFF_URL"] || "auth.org.localhost"
    @headers = { "Host" => @host, "X-TEST-CURRENT-STAFF" => @staff.id }.freeze
  end

  test "index returns empty collection" do
    get auth_org_setting_sessions_url, headers: @headers

    assert_response :success
    assert_empty response.parsed_body["sessions"]
  end

  test "lifecycle: create, show, update, destroy" do
    post auth_org_setting_sessions_url, params: { session: { name: "Org Session" } }, headers: @headers
    assert_response :created
    created = response.parsed_body.fetch("session")

    get auth_org_setting_session_url(created["id"]), headers: @headers
    assert_response :success

    patch auth_org_setting_session_url(created["id"]),
          params: { session: { status: "revoked" } },
          headers: @headers
    assert_response :success
    assert_equal "revoked", response.parsed_body.dig("session", "status")

    delete auth_org_setting_session_url(created["id"]), headers: @headers
    assert_response :see_other

    get auth_org_setting_session_url(created["id"]), headers: @headers
    assert_response :not_found
  end

  test "requires authentication" do
    get auth_org_setting_sessions_url, headers: { "Host" => @host }

    assert_response :redirect
  end
end
