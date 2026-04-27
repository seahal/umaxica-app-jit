# typed: false
# frozen_string_literal: true

require "test_helper"

class Sign::Com::In::EmailsControllerTest < ActionDispatch::IntegrationTest
  include ActiveSupport::Testing::TimeHelpers

  setup do
    host! ENV.fetch("ID_CORPORATE_URL", "id.com.localhost")
    @host = ENV.fetch("ID_CORPORATE_URL", "id.com.localhost")
    ActionMailer::Base.deliveries.clear
    CloudflareTurnstile.test_mode = true
    CloudflareTurnstile.test_validation_response = { "success" => true }
  end

  teardown do
    CloudflareTurnstile.test_mode = false
    CloudflareTurnstile.test_validation_response = nil
  end

  test "get new renders email form" do
    get new_sign_com_in_email_url(ri: "jp"), headers: { "Host" => @host }

    assert_response :success
    assert_includes response.body, I18n.t("sign.app.authentication.email.new.page_title")
  end

  test "post create with unknown email redirects to edit without customer email session id" do
    assert_no_difference -> { ActionMailer::Base.deliveries.count } do
      post sign_com_in_email_url(ri: "jp"),
           params: {
             user_email: { address: "missing-customer@example.com" },
             "cf-turnstile-response": "test",
           },
           headers: { "Host" => @host }

      assert_response :redirect
      assert_redirected_to %r{/in/email/edit}
      assert_nil session[:user_email_authentication_id]
    end
  end

  test "post create with existing customer email redirects to edit" do
    customer = create_verified_customer_with_email(email_address: "com-login-#{SecureRandom.hex(4)}@example.com")
    email = customer.customer_emails.last

    post sign_com_in_email_url(ri: "jp"),
         params: {
           user_email: { address: email.address },
           "cf-turnstile-response": "test",
         },
         headers: { "Host" => @host }

    assert_response :redirect
    assert_redirected_to %r{/in/email/edit}
  end
end
