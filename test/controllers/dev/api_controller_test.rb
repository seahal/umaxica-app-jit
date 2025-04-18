require "test_helper"

class Dev::ApiControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get dev_api_url
    assert_response :success
    assert_select "a[href=?]", dev_root_path, count: 2
    assert_select "a[href=?]", dev_api_com_path, count: 0
    #    assert_select "a[href=?]", dev_api_app_path, count: 1
    #    assert_select "a[href=?]", dev_api_org_path, count: 1
  end
end
