require "test_helper"

class Sign::App::Registration::EmailsControllerTest < ActionDispatch::IntegrationTest
  include ActiveSupport::Testing::TimeHelpers

  # test "should get new" do
  #   get new_sign_app_registration_email_url, headers: { "Host" => host }
  #   assert_response :success
  # end
  #
  # test "dom structure includes inputs turnstile and submit button" do
  #   get new_sign_app_registration_email_url, headers: { "Host" => host }
  #   assert_response :success
  #
  #   assert_select "h1", I18n.t("sign.app.registration.email.new.page_title")
  #   expected_action = sign_app_registration_emails_path(default_url_query)
  #   assert_select "form[action=?][method=?]", expected_action, "post" do
  #     assert_select "input[type=?][name=?]", "email", "user_email[address]"
  #     assert_select "input[type=?][name=?]", "checkbox", "user_email[confirm_policy]"
  #     assert_select "div.cf-turnstile", 1
  #     assert_select "input[type=?]", "submit"
  #   end
  # end
  #
  # test "includes navigation links to other registration flows" do
  #   get new_sign_app_registration_email_url, headers: { "Host" => host }
  #   assert_response :success
  #
  #   assert_select "a[href=?]", new_sign_app_registration_path(default_url_query), count: 1
  #   assert_select "a[href=?]", new_sign_app_authentication_email_path(default_url_query), count: 1
  # end
end
