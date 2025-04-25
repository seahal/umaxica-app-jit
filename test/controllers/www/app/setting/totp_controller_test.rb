require "test_helper"

class Www::App::Registration::ApplesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get www_app_setting_totp_index_url
    assert_response :success
  end

  test "should get new" do
    get new_www_app_setting_totp_url
    assert_select "label[for=?]", "user_time_based_one_time_password_first_token", count: 1
    assert_select "input[name=?]", "user_time_based_one_time_password[first_token]", count: 1
    assert_select "label[for=?]", "user_time_based_one_time_password_second_token", count: 1
    assert_select "input[name=?]", "user_time_based_one_time_password[second_token]", count: 1
    assert_select "input[type=?]", "submit", count: 1
    assert_response :success
  end
end
