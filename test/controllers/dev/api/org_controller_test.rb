require "test_helper"

class Dev::Api::OrgControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get dev_api_org_url
    assert_response :success
    assert_select "a[href=?]", dev_api_path, count: 1
  end
end
