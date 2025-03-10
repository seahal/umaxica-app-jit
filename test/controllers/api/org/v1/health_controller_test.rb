require "test_helper"

class Api::Org::V1::HealthControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get api_org_v1_health_show_url
    assert_response :success
  end
end
