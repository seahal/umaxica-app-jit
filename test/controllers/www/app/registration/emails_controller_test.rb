require "test_helper"

class Www::App::Registration::EmailsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_www_app_registration_email_url
    assert_response :success
  end

  test "should show link for sign in pages" do
    get new_www_app_registration_email_url
    assert_select "a[href=?]", new_www_app_session_email_path, count: 1
  end

  test "DOM validation" do
    get new_www_app_registration_email_url
    assert_select "input#user_email_address"
    assert_select "input#user_email_confirm_policy"

    assert_select "form[action=?][method=?]", www_app_registration_emails_path, "post" do
      # email入力フィールドの存在と属性チェック
      assert_select "input[type=?][name=?]", "email", "user_email[address]"

      # checkboxの存在と属性チェック
      assert_select "input[type=?][name=?]", "checkbox", "user_email[confirm_policy]"

      # cloudflare tunstile
      assert_select "div.cf-turnstile"

      # submitボタンの存在
      assert_select "input[type=?]", "submit"
    end
  end
end
