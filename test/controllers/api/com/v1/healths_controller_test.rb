require "test_helper"

class Api::Com::V1::HealthsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get api_com_v1_health_url
    assert_response :success
  end
end
