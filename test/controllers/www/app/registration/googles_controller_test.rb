require "test_helper"

class Net::Registration::GooglesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_net_registration_google_url
    assert_response :success
    assert_select "a[href=?]", net_root_path, count: 2
  end
end
