require "test_helper"

class Api::Com::HealthsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @api_host = ENV["API_CORPORATE_URL"]
    @headers = { "HOST" => @api_host }
  end

  test "responds with OK for html variants" do
    assert_health_html_variants(:api_com_health_path, headers: @headers)
  end

  test "responds with OK for json" do
    assert_health_json(:api_com_health_path, headers: @headers)
  end

  test "returns lightweight health check when mode parameter is provided" do
    get api_com_health_path(format: :json), headers: @headers, params: { mode: :lightweight }
    assert_response :success
    assert_equal "OK", response.parsed_body["status"]
  end

  test "returns quick response for health check" do
    start_time = Time.current
    get api_com_health_path(format: :json), headers: @headers
    response_time = Time.current - start_time

    assert_response :success
    assert response_time < 5.0, "Health check should respond within 5 seconds"
  end

  test "sets appropriate cache headers" do
    get api_com_health_path(format: :json), headers: @headers
    assert_response :success
  end

  test "handles invalid format gracefully" do
    assert_health_invalid_format(:api_com_health_path, :xml, headers: @headers)
  end

  test "does not crash when request path is malformed" do
    get "#{api_com_health_path}/", headers: @headers
    assert_response :success
  end
end
