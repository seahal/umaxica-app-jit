require "test_helper"

class Api::Org::HealthsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @api_host = ENV["API_STAFF_URL"]
  end

  test "should get health json with 200 status" do
    get "/health.json", headers: { "HOST" => @api_host }
    assert_response :success
    assert_equal 200, response.status
    json_response = response.parsed_body
    assert_equal "OK", json_response["status"]
  end

  test "should get health html with 200 status" do
    get "/health", headers: { "HOST" => @api_host }
    assert_response :success
    assert_equal 200, response.status
    assert_includes response.body, "OK"
  end

  test "should get health html format with 200 status" do
    get "/health.html", headers: { "HOST" => @api_host }
    assert_response :success
    assert_equal 200, response.status
    assert_includes response.body, "OK"
  end

  test "should return lightweight health check when mode parameter is provided" do
    get "/health.json?mode=lightweight", headers: { "HOST" => @api_host }
    assert_response :success
    json_response = response.parsed_body
    assert_equal "OK", json_response["status"]
  end

  test "should return quick response for health check" do
    start_time = Time.current
    get "/health.json", headers: { "HOST" => @api_host }
    response_time = Time.current - start_time

    assert_response :success
    assert response_time < 5.0, "Health check should respond within 5 seconds"
  end

  test "should set appropriate cache headers" do
    get "/health.json", headers: { "HOST" => @api_host }
    assert_response :success
    assert_equal "public", response.headers["Cache-Control"].split(", ").find { |directive| directive == "public" }
    assert response.headers["Cache-Control"].include?("max-age=1")
  end

  test "should handle staff-specific health checks" do
    get "/health.json", headers: { "HOST" => @api_host, "User-Agent" => "StaffMonitoring/1.0" }
    assert_response :success
    json_response = response.parsed_body
    assert_equal "OK", json_response["status"]
  end
end
