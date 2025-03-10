require "test_helper"

class Dev::Www::ComControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get dev_www_com_url
    assert_response :success
    assert_select "a[href=?]", dev_www_path, count: 1
  end
end
