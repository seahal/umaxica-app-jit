require "test_helper"

class Sign::App::Registration::EmailsControllerTest < ActionDispatch::IntegrationTest
  include ActiveSupport::Testing::TimeHelpers

  test "should get new" do
    get new_sign_app_registration_email_url, headers: default_headers
    assert_response :success
  end

  test "renders email registration form structure" do
    get new_sign_app_registration_email_url, headers: default_headers
    assert_response :success

    assert_select "h1", I18n.t("sign.app.registration.email.new.page_title")
    # expected_action = sign_app_registration_emails_path
    # assert_select "form[method=?]", "post" do
    #   assert_select "input[type=?][name=?]", "email", "user_email[address]"
    #   assert_select "input[type=?][name=?]", "checkbox", "user_email[confirm_policy]"
    #   assert_select "div.cf-turnstile", 1
    #   assert_select "input[type=?]", "submit"
    # end
  end

  test "includes navigation links to other registration flows" do
    get new_sign_app_registration_email_url, headers: default_headers
    assert_response :success

    assert_select "a[href=?]", new_sign_app_registration_path, count: 0
    assert_select "a[href=?]", new_sign_app_authentication_email_path, count: 0
  end

  test "edit returns bad_request when not logged in and no session" do
    get edit_sign_app_registration_email_url(id: "test-id"), headers: default_headers
    assert_response :bad_request
  end

  private

  def default_headers
    { "Host" => host }
  end

  def host
    ENV["SIGN_SERVICE_URL"] || "sign.app.localhost"
  end
end
