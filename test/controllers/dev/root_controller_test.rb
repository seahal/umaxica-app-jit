require "test_helper"

class Dev::RootControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get dev_root_url
    assert_response :success
    assert_select "a[href=?]", dev_root_path, count: 2
    assert_select "a[href=?]", dev_api_path, count: 1
    assert_select "a[href=?]", dev_www_path, count: 1
  end
end
