# frozen_string_literal: true

require "test_helper"

class Sign::App::Configuration::EmergencyKeysControllerTest < ActionDispatch::IntegrationTest
  fixtures :users, :user_statuses, :user_secret_kinds, :user_secret_statuses, :user_passkey_statuses

  setup do
    host! ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
    @host = ENV["SIGN_SERVICE_URL"] || "sign.app.localhost"
    @user = create_verified_user_with_email(email_address: "emergency_key_test@example.com")
    @token = UserToken.create!(user_id: @user.id)
    @headers = {
      "Host" => @host,
      "X-TEST-CURRENT-USER" => @user.id,
      "X-TEST-SESSION-PUBLIC-ID" => @token.public_id,
    }.freeze

    @original_trusted_origins = Webauthn.method(:trusted_origins)
    allowed_origins = [
      "http://#{@host}",
      "https://#{@host}",
    ].uniq
    Webauthn.define_singleton_method(:trusted_origins) { allowed_origins }
  end

  teardown do
    Webauthn.define_singleton_method(:trusted_origins, @original_trusted_origins)
  end

  test "show displays emergency key once from session" do
    UserSecret.stub :generate_raw_secret, "RECOVERY-KEY-1234567890123456789" do
      post options_sign_app_configuration_passkeys_url(ri: "jp"), headers: @headers
      assert_response :ok
      challenge_id = response.parsed_body["challenge_id"]
      assert_predicate challenge_id, :present?

      mock_credential = Object.new
      mock_credential.define_singleton_method(:id) { "emergency_webauthn_id" }
      mock_credential.define_singleton_method(:public_key) { "emergency_public_key" }
      mock_credential.define_singleton_method(:sign_count) { 1 }
      mock_credential.define_singleton_method(:verify) { |*_args| true }

      WebAuthn::Credential.stub :from_create, mock_credential do
        post verification_sign_app_configuration_passkeys_url(ri: "jp"),
             params: {
               challenge_id: challenge_id,
               credential: {
                 id: "emergency_webauthn_id",
                 response: { clientDataJSON: "e30=", attestationObject: "e30=" },
               },
             },
             headers: @headers
      end

      assert_response :created
      assert_equal "ok", response.parsed_body["status"]
      assert_equal sign_app_configuration_emergency_key_path(ri: "jp"), response.parsed_body["redirect_url"]
      assert_equal "RECOVERY-KEY-1234567890123456789", session[:recovery_secret_raw]

      get sign_app_configuration_emergency_key_url(ri: "jp"), headers: @headers
    end

    assert_response :success
    assert_includes response.body, "RECOVERY-KEY-1234567890123456789"
  end

  test "show redirects when emergency key is missing" do
    get sign_app_configuration_emergency_key_url(ri: "jp"), headers: @headers

    assert_response :redirect
    assert_redirected_to sign_app_configuration_url(ri: "jp")
    assert_equal I18n.t("sign.app.configuration.emergency_key.missing"), flash[:alert]
  end
end
