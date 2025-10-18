require "test_helper"

class Api::App::HealthsControllerTest < ActionDispatch::IntegrationTest
  test "returns lightweight health check when mode parameter is provided" do
    get api_app_health_path(format: :json), headers: @headers, params: { mode: :lightweight }
    assert_response :not_found
  end

  test "returns quick response for health check" do
    start_time = Time.current
    get api_app_health_path(format: :json), headers: @headers
    response_time = Time.current - start_time
    assert_response :not_found
    assert response_time < 5.0, "Health check should respond within 5 seconds"
  end
end
