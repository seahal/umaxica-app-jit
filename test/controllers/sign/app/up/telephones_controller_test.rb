# frozen_string_literal: true

require "test_helper"

module Sign::App::Up
  class TelephonesControllerTest < ActionDispatch::IntegrationTest
    include ActiveJob::TestHelper

    setup do
      host! ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")

      CloudflareTurnstile.test_mode = true
      CloudflareTurnstile.test_validation_response = { "success" => true }

      @original_send_message = AwsSmsService.method(:send_message)
      AwsSmsService.singleton_class.send(:define_method, :send_message) do |**_kwargs|
        true
      end
    end

    teardown do
      CloudflareTurnstile.test_mode = false
      CloudflareTurnstile.test_validation_response = nil

      original = @original_send_message
      AwsSmsService.singleton_class.send(:define_method, :send_message) do |**kwargs|
        original.call(**kwargs)
      end
    end

    test "should get new" do
      get new_sign_app_up_telephone_url(ri: "jp"), headers: default_headers
      assert_response :success
    end

    test "create redirects to edit and preserves rd" do
      encoded_rd = Base64.urlsafe_encode64("/dashboard")

      post sign_app_up_telephones_url(ri: "jp"),
           params: {
             user_telephone: {
               number: "+1234567890",
               confirm_policy: "1",
               confirm_using_mfa: "1"
             },
             "cf-turnstile-response": "test",
             rd: encoded_rd
           },
           headers: default_headers

      assert_response :redirect
      assert_includes response.location, "rd=#{CGI.escape(encoded_rd)}"
      assert_match(%r{/up/telephones/[^/]+/edit}, response.location)
    end

    test "successful OTP verification redirects to rd" do
      encoded_rd = Base64.urlsafe_encode64("/dashboard")

      post sign_app_up_telephones_url(ri: "jp"),
           params: {
             user_telephone: {
               number: "+1234567890",
               confirm_policy: "1",
               confirm_using_mfa: "1"
             },
             "cf-turnstile-response": "test",
             rd: encoded_rd
           },
           headers: default_headers

      telephone_id = response.location.match(%r{/up/telephones/([^/]+)/edit})[1]
      user_telephone = UserTelephone.find_by(id: telephone_id)

      otp_data = user_telephone.get_otp
      hotp = ROTP::HOTP.new(otp_data[:otp_private_key])
      correct_code = hotp.at(otp_data[:otp_counter]).to_s

      patch sign_app_up_telephone_url(user_telephone, ri: "jp"),
            params: {
              user_telephone: { pass_code: correct_code },
              rd: encoded_rd
            },
            headers: default_headers

      assert_redirected_to "/dashboard"
    end

    test "OTP replay after success returns 409" do
      post sign_app_up_telephones_url(ri: "jp"),
           params: {
             user_telephone: {
               number: "+1234567890",
               confirm_policy: "1",
               confirm_using_mfa: "1"
             },
             "cf-turnstile-response": "test"
           },
           headers: default_headers

      telephone_id = response.location.match(%r{/up/telephones/([^/]+)/edit})[1]
      user_telephone = UserTelephone.find_by(id: telephone_id)

      otp_data = user_telephone.get_otp
      hotp = ROTP::HOTP.new(otp_data[:otp_private_key])
      correct_code = hotp.at(otp_data[:otp_counter]).to_s

      patch sign_app_up_telephone_url(user_telephone, ri: "jp"),
            params: { user_telephone: { pass_code: correct_code } },
            headers: default_headers

      assert_response :redirect

      cookies.delete(::Auth::User::ACCESS_COOKIE_KEY)
      cookies.delete(::Auth::User::REFRESH_COOKIE_KEY)

      patch sign_app_up_telephone_url(user_telephone, ri: "jp"),
            params: { user_telephone: { pass_code: correct_code } },
            headers: default_headers

      assert_response :conflict
    end

    private

      def default_headers
        { "Host" => host, "HTTPS" => "on" }
      end

      def host
        ENV["SIGN_SERVICE_URL"] || "sign.app.localhost"
      end
  end
end
