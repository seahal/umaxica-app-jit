require "test_helper"


class Sign::App::Authentication::EmailsControllerTest < ActionDispatch::IntegrationTest
  # rubocop:disable Minitest/MultipleAssertions
  test "should get new" do
    get new_sign_app_authentication_email_url, headers: { "Host" => ENV["SIGN_SERVICE_URL"] }

    assert_select "h1", I18n.t("sign.app.authentication.email.new.page_title")
    assert_select "ul li" do
      assert_select "a", I18n.t("sign.app.authentication.new.back")
      assert_select "a", I18n.t("sign.app.authentication.email.new.registration")
    end
    #    assert_select "a[href=?]", new_sign_app_authentication_path
    # assert_select "form[action=?][method=?]", sign_app_authentication_email_path, "post" do
    #   # Check existence and attributes of email input field
    #   assert_select "input[type=?][name=?]", "email", "user_email[address]"
    #   # cloudflare tunstile
    #   assert_select "div.cf-turnstile"
    #   # Check existence of submit button
    #   assert_select "input[type=?]", "submit"
    # end
    assert_not cookies[:htop_private_key].nil?
    #    assert_select "a[href=?]", new_sign_app_authentication_path(query), I18n.t("sign.app.authentication.new.back")
    assert_response :success
  end
  # rubocop:enable Minitest/MultipleAssertions

  # FIXME: implement this test
  test "reject already logged in user" do
    get new_sign_app_authentication_email_url, headers: { "Host" => ENV["SIGN_SERVICE_URL"] }

    assert_response :success
  end

  # FIXME: implement this test
  test "reject already logged in staff" do
    get new_sign_app_authentication_email_url, headers: { "Host" => ENV["SIGN_SERVICE_URL"] }

    assert_response :success
  end
end
