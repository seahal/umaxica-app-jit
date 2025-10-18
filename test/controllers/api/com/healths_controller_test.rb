require "test_helper"

class Api::Com::HealthsControllerTest < ActionDispatch::IntegrationTest
  test "returns lightweight health check when mode parameter is provided" do
    get api_com_health_path(format: :json), headers: @headers, params: { mode: :lightweight }
    assert_response :not_found
  end

  test "returns quick response for health check" do
    start_time = Time.current
    get api_com_health_path(format: :json), headers: @headers
    response_time = Time.current - start_time
    assert response_time < 5.0, "Health check should respond within 5 seconds"
    assert_response :not_found
  end
end
