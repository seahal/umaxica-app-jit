# typed: false
# frozen_string_literal: true

require "test_helper"
require "base64"

class Sign::Com::Verification::EmailsControllerTest < ActionDispatch::IntegrationTest
  fixtures :users

  setup do
    @host = ENV.fetch("SIGN_CORPORATE_URL", "sign.com.localhost")
    host! @host
    @user = create_verified_user_with_email(email_address: "com-verified-#{SecureRandom.hex(4)}@example.com")
    @user.user_telephones.create!(
      number: "+8190#{SecureRandom.random_number(10**8).to_s.rjust(8, '0')}",
      user_telephone_status_id: UserTelephoneStatus::VERIFIED,
    )
    @headers = as_user_headers(@user, host: @host)
    @token = UserToken.find_by!(public_id: @headers["X-TEST-SESSION-PUBLIC-ID"])
  end

  test "new sends otp and redirects to edit" do
    return_to = Base64.urlsafe_encode64(sign_com_configuration_emails_path(ri: "jp"))

    Sign::Com::Verification::BaseController.any_instance.stub(:available_step_up_methods, [:email_otp]) do
      Sign::Com::Verification::BaseController.any_instance.stub(:send_email_otp!, true) do
        get sign_com_verification_url(scope: "configuration_email", return_to: return_to, ri: "jp"),
            headers: @headers

        get new_sign_com_verification_email_url(ri: "jp"), headers: @headers

        assert_response :redirect
        assert_match %r{/verification/emails/.+/edit}, response.location
      end
    end
  end

  test "update verifies otp and redirects to return_to" do
    return_to = Base64.urlsafe_encode64(sign_com_configuration_emails_path(ri: "jp"))

    Sign::Com::Verification::BaseController.any_instance.stub(:available_step_up_methods, [:email_otp]) do
      Sign::Com::Verification::BaseController.any_instance.stub(:send_email_otp!, true) do
        get sign_com_verification_url(scope: "configuration_email", return_to: return_to, ri: "jp"),
            headers: @headers

        get new_sign_com_verification_email_url(ri: "jp"), headers: @headers
        nonce = response.location[%r{/verification/emails/([^/]+)/edit}, 1]

        Sign::Com::Verification::BaseController.any_instance.stub(:verify_email_otp!, true) do
          patch sign_com_verification_email_url(nonce, ri: "jp"),
                params: { verification: { code: "123456" } },
                headers: @headers

          assert_response :redirect
          assert_redirected_to sign_com_configuration_emails_url(ri: "jp")
        end
      end
    end
  end

  test "step up flow from configuration emails returns to original page" do
    stale_token = UserToken.create!(user_id: @user.id, created_at: 20.minutes.ago, updated_at: 20.minutes.ago)
    stale_headers = @headers.merge("X-TEST-SESSION-PUBLIC-ID" => stale_token.public_id)

    Sign::Com::Verification::BaseController.any_instance.stub(:available_step_up_methods, [:email_otp]) do
      get sign_com_configuration_emails_url(ri: "jp"), headers: stale_headers

      assert_response :redirect

      query = Rack::Utils.parse_nested_query(URI(response.location).query)
      scope = query["scope"]
      return_to = query["rd"] || query["return_to"]

      assert_equal "configuration_email", scope
      assert_predicate return_to, :present?

      get sign_com_verification_url(scope: scope, rd: return_to, ri: "jp"), headers: stale_headers

      assert_response :success

      Sign::Com::Verification::BaseController.any_instance.stub(:send_email_otp!, true) do
        post sign_com_verification_emails_url(ri: "jp"),
             params: { verification: { scope: scope, rd: return_to } },
             headers: stale_headers
      end

      assert_response :redirect
      nonce = response.location[%r{/verification/emails/([^/]+)/edit}, 1]

      assert_predicate nonce, :present?

      Sign::Com::Verification::BaseController.any_instance.stub(:verify_email_otp!, true) do
        patch sign_com_verification_email_url(nonce, ri: "jp"),
              params: { verification: { code: "123456", scope: scope, rd: return_to } },
              headers: stale_headers
      end

      assert_response :redirect
      assert_redirected_to sign_com_configuration_emails_url(ri: "jp")
    end
  end
end
