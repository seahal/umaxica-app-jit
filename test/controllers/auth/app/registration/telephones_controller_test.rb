require "test_helper"

class Www::App::Registration::TelephonesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_auth_app_registration_telephone_url, headers: { "Host" => ENV["AUTH_SERVICE_URL"] }
    assert_response :success
    assert_select "form[action=?][method=?]", auth_app_registration_telephones_path, "post" do
      # Check existence and attributes of telephone input field
      assert_select "label[for=?]", "user_telephone_number"
      assert_select "input[type=?][name=?]", "text", "user_telephone[number]"
      # Check existence and attributes of checkbox
      assert_select "label[for=?]", "user_telephone_confirm_policy"
      assert_select "input[type=?][name=?]", "checkbox", "user_telephone[confirm_policy]"
      assert_select "input[type=?][name=?]", "hidden", "user_telephone[confirm_policy]"
      # Check existence and attributes of checkbox
      assert_select "label[for=?]", "user_telephone_confirm_using_mfa"
      assert_select "input[type=?][name=?]", "hidden", "user_telephone[confirm_using_mfa]"
      assert_select "input[type=?][name=?]", "checkbox", "user_telephone[confirm_using_mfa]"
      # cloudflare tunstile
      assert_select "div.cf-turnstile", 1..1
      # submitボタンの存在
      assert_select "input[type=?]", "submit"
    end
    assert_select "a[href=?]", new_auth_app_registration_path
    assert_select "a[href=?]", new_auth_app_authentication_telephone_path
  end
end
