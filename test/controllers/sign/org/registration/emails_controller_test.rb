# frozen_string_literal: true

require "test_helper"

module Sign::Org::Registration
  class EmailsControllerTest < ActionDispatch::IntegrationTest
    test "should get new" do
      get new_sign_org_registration_email_url

      assert_response :success
    end

    test "should clear session on new" do
      get new_sign_org_registration_email_url

      assert_response :success
      assert_nil session[:user_email_registration]
    end

    test "should render bad request if logged in on edit" do
      get edit_sign_org_registration_email_url(id: "test")

      assert_response :bad_request
    end

    test "should redirect if session expired on edit" do
      get edit_sign_org_registration_email_url(id: "test")

      assert_redirected_to new_sign_org_registration_email_path
    end

    # TODO: Uncomment when Email::App::EmailRegistrationMailer is available
    # test "should create email registration" do
    #   post sign_org_registration_emails_url, params: {
    #     user_email: {
    #       address: "test@example.com",
    #       confirm_policy: "1"
    #     },
    #     "cf-turnstile-response": "test_token"
    #   }
    #
    #   # Should redirect on success or render on failure
    #   assert_response :redirect
    # end
  end
end
