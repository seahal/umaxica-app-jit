require "test_helper"

class Auth::App::Registration::EmailsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_auth_app_registration_email_url, headers: { "Host" => ENV["AUTH_SERVICE_URL"] }
    assert_response :success
  end

  # test "should show link for sign in pages" do
  #   get new_auth_app_registration_email_url, headers: { "Host" => ENV["AUTH_SERVICE_URL"] }
  #   assert_select "a[href=?]", new_auth_app_authentication_email_path, count: 1
  # end
  #
  # test "DOM validation" do
  #   get new_auth_app_registration_email_url, headers: { "Host" => ENV["AUTH_SERVICE_URL"] }
  #   assert_select "input#user_email_address"
  #   assert_select "input#user_email_confirm_policy"
  #   assert_select "h1", I18n.t("auth.app.registration.email.new.page_title")
  #   assert_select "form[action=?][method=?]", auth_app_registration_emails_path, "post" do
  #     # Check existence and attributes of email input field
  #     assert_select "input[type=?][name=?]", "email", "user_email[address]"
  #     # Check existence and attributes of checkbox
  #     assert_select "input[type=?][name=?]", "checkbox", "user_email[confirm_policy]"
  #     # cloudflare tunstile
  #     assert_select "div.cf-turnstile", 1..1
  #     # Check existence of submit button
  #     assert_select "input[type=?]", "submit"
  #   end
  # end

  # TODO(human)
end
