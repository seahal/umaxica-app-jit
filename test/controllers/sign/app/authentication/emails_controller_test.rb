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
    assert_nil cookies[:htop_private_key]
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
  setup do
    @host = ENV["SIGN_SERVICE_URL"] || "sign.app.localhost"
    ActionMailer::Base.deliveries.clear
  end

  test "GET new displays email form" do
    get new_sign_app_authentication_email_url, headers: { "Host" => @host }

    assert_response :success
    assert_select "input[name='user_identity_email[address]']"
  end

  test "POST create without valid email redirects (enumeration protection)" do
    post sign_app_authentication_email_url,
         params: { user_identity_email: { address: "nonexistent@example.com" } },
         headers: { "Host" => @host }

    # Should redirect to edit to prevent enumeration
    assert_response :found
    assert_redirected_to %r{/authentication/email/edit}
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "POST create with unknown email does not issue otp" do
    assert_no_difference -> { ActionMailer::Base.deliveries.count } do
      post sign_app_authentication_email_url,
           params: { user_identity_email: { address: "missing-user@example.com" } },
           headers: { "Host" => @host }

      assert_response :found
      assert_redirected_to %r{/authentication/email/edit}
      # Session should not have ID, but might have address
      assert_nil session[:user_email_authentication_id]
    end
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "POST create with existing email generates OTP and redirects to edit" do
    skip "Pending Turnstile mock implementation"
    # Create a test email in the database
    test_email = "auth_test_#{SecureRandom.hex(4)}@example.com"
    UserIdentityEmail.create!(address: test_email) rescue nil

    # Make the POST request with valid email and Turnstile response
    post sign_app_authentication_email_url,
         params: {
           user_identity_email: { address: test_email },
           "cf-turnstile-response" => "test_token"
         },
         headers: { "Host" => @host }

    assert_response :redirect
  end
end
