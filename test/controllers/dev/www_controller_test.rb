require "test_helper"

class Dev::WwwControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get dev_www_url
    assert_response :success
    assert_select "a[href=?]", dev_root_path, count: 3
    assert_select "a[href=?]", dev_www_com_path, count: 1
    assert_select "a[href=?]", dev_www_net_path, count: 1
    assert_select "a[href=?]", dev_www_org_path, count: 1
  end
end
