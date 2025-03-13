require "test_helper"

class Dev::Api::AppControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get dev_api_app_url
    assert_response :success
    assert_select "a[href=?]", dev_api_path, count: 1
  end
end
