require "test_helper"

class Www::App::Registration::EmailsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_www_app_registration_email_url
    assert_response :success
  end

  test "should show link for sign in pages" do
    get new_www_app_registration_email_url
    assert_select "a[href=?]", new_www_app_authentication_email_path, count: 1
  end

  test "DOM validation" do
    get new_www_app_registration_email_url
    assert_select "input#user_email_address"
    assert_select "input#user_email_confirm_policy"
    assert_select "h1", I18n.t("www.app.registration.email.new.page_title")
    assert_select "form[action=?][method=?]", www_app_registration_emails_path, "post" do
      # Check existence and attributes of email input field
      assert_select "input[type=?][name=?]", "email", "user_email[address]"
      # Check existence and attributes of checkbox
      assert_select "input[type=?][name=?]", "checkbox", "user_email[confirm_policy]"
      # cloudflare tunstile
      assert_select "div.cf-turnstile", 1..1
      # submitボタンの存在
      assert_select "input[type=?]", "submit"
    end
  end
end
