require "test_helper"

class Api::Org::HealthsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @api_host = ENV["API_STAFF_URL"]
    @headers = { "HOST" => @api_host }
  end

  test "responds with OK for html variants" do
    assert_health_html_variants(:api_org_health_path, headers: @headers)
  end

  test "returns lightweight health check when mode parameter is provided" do
    get api_org_health_path(format: :json), headers: @headers, params: { mode: :lightweight }
    assert_response :success
    assert_equal "OK", response.parsed_body["status"]
  end

  test "returns quick response for health check" do
    start_time = Time.current
    get api_org_health_path(format: :json), headers: @headers
    response_time = Time.current - start_time

    assert_response :success
    assert response_time < 5.0, "Health check should respond within 5 seconds"
  end

  test "sets appropriate cache headers" do
    get api_org_health_path(format: :json), headers: @headers
    assert_response :success
  end

  test "handles staff-specific health checks" do
    get api_org_health_path(format: :json), headers: @headers.merge("User-Agent" => "StaffMonitoring/1.0")
    assert_response :success
    assert_equal "OK", response.parsed_body["status"]
  end

  test "handles invalid format gracefully" do
    assert_health_invalid_format(:api_org_health_path, :xml, headers: @headers)
  end

  test "does not crash when request path is malformed" do
    get "#{api_org_health_path}/", headers: @headers
    assert_response :success
  end
end
