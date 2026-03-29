# typed: false
# frozen_string_literal: true

require "test_helper"

class Sign::Com::Up::EmailsControllerTest < ActionDispatch::IntegrationTest
  include ActiveSupport::Testing::TimeHelpers

  setup do
    host! ENV.fetch("SIGN_CORPORATE_URL", "sign.com.localhost")
    CloudflareTurnstile.test_mode = true
    CloudflareTurnstile.test_validation_response = { "success" => true }
  end

  teardown do
    CloudflareTurnstile.test_mode = false
    CloudflareTurnstile.test_validation_response = nil
  end

  test "should get new" do
    get new_sign_com_up_email_url(ri: "jp"), headers: default_headers

    assert_response :success
  end

  test "includes navigation link back to sign in" do
    get new_sign_com_up_email_url(ri: "jp"), headers: default_headers

    assert_response :success
    assert_select "a[href=?]", new_sign_com_in_path(ri: "jp"), count: 1
  end

  test "create redirects to edit and allows edit page" do
    post sign_com_up_emails_url(ri: "jp"),
         params: {
           user_email: {
             raw_address: "com-flow-step@example.com",
             confirm_policy: "1",
           },
           "cf-turnstile-response": "test",
         },
         headers: default_headers

    assert_response :redirect

    follow_redirect!

    assert_response :success
    assert_match(%r{/up/emails/[^/]+/edit}, path)
  end

  test "create with existing email still redirects and does not create a new record" do
    user = User.create!(status_id: UserStatus::VERIFIED_WITH_SIGN_UP)
    existing_email = UserEmail.create!(
      user: user,
      address: "com-existing-signup@example.com",
      confirm_policy: "1",
      user_email_status_id: UserEmailStatus::VERIFIED,
    )

    assert_no_difference("User.count") do
      assert_no_difference("UserEmail.count") do
        assert_enqueued_emails 0 do
          post sign_com_up_emails_url(ri: "jp"),
               params: {
                 user_email: {
                   raw_address: existing_email.address,
                   confirm_policy: "1",
                 },
                 "cf-turnstile-response": "test",
               },
               headers: default_headers
        end
      end
    end

    assert_response :redirect
    assert_includes response.location, "/up/emails/#{existing_email.public_id}/edit"
    assert_equal I18n.t("sign.app.registration.email.create.verification_code_sent"), flash[:notice]
  end

  private

  def default_headers
    { "Host" => host, "HTTPS" => "on" }
  end

  def host
    ENV["SIGN_CORPORATE_URL"] || "sign.com.localhost"
  end
end
