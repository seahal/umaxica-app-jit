require "test_helper"

class Net::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_net_registration_url
    assert_response :success
    assert_select "a[href=?]", new_net_registration_email_path, count: 1
    assert_select "a[href=?]", new_net_registration_apple_path, count: 1
    assert_select "a[href=?]", new_net_registration_google_path, count: 1
    assert_select "a[href=?]", new_net_registration_telephone_path, count: 1
    assert_select "a[href=?]", new_net_session_path, count: 1
    assert_select "a[href=?]", net_root_path, count: 2
  end
end
