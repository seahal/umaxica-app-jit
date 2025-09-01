require "test_helper"

class Api::Org::HealthsControllerTest < ActionDispatch::IntegrationTest
  test "should get health json with 200 status" do
    get "/health.json", headers: { "HOST" => ENV["API_STAFF_URL"] }
    assert_response :success
    assert_equal 200, response.status
    json_response = response.parsed_body
    assert_equal "OK", json_response["status"]
  end

  test "should get health html with 200 status" do
    get "/health", headers: { "HOST" => ENV["API_STAFF_URL"] }
    assert_response :success
    assert_equal 200, response.status
  end

  test "should get health html format with 200 status" do
    get "/health.html", headers: { "HOST" => ENV["API_STAFF_URL"] }
    assert_response :success
    assert_equal 200, response.status
  end
end
