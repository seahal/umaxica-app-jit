# frozen_string_literal: true

require "test_helper"
require "minitest/mock"

class Sign::App::Configuration::PasskeysControllerTest < ActionDispatch::IntegrationTest
  fixtures :users, :user_statuses

  setup do
    host! ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
    @user = users(:one)
    @headers = { "X-TEST-CURRENT-USER" => @user.id }.freeze

    # Cleanup potentially corrupted UserEmails
    UserEmail.delete_all

    # Mock TRUSTED_ORIGINS
    @original_trusted_origins = Webauthn.method(:trusted_origins)
    allowed_origins = [
      "http://sign.app.localhost",
      "http://sign.org.localhost",
      "http://www.example.com",
      "http://#{ENV.fetch("SIGN_SERVICE_URL", "sign.umaxica.app")}",
      "https://#{ENV.fetch("SIGN_SERVICE_URL", "sign.umaxica.app")}",
    ].uniq
    Webauthn.define_singleton_method(:trusted_origins) { allowed_origins }
  end

  teardown do
    Webauthn.define_singleton_method(:trusted_origins, @original_trusted_origins)
  end

  # Case D-1: Not logged in
  test "options redirects when not logged in" do
    post options_sign_app_configuration_passkeys_path(ri: "jp")
    assert_response :redirect
  end

  # Case D-2: Logged in -> JSON options
  test "options returns challenge and options" do
    post options_sign_app_configuration_passkeys_path(ri: "jp"), headers: @headers

    assert_response :ok
    json = response.parsed_body

    assert_not_nil json["challenge_id"]
    assert_not_nil json["options"]

    # Check session
    assert_not_nil session[:passkey_challenges][json["challenge_id"]]
    assert_equal "registration", session[:passkey_challenges][json["challenge_id"]]["purpose"]
  end

  # Case D-3: Untrusted origin
  test "options rejects untrusted origin" do
    # Temporarily remove trusted origins
    Webauthn.stub :trusted_origins, [] do
      post options_sign_app_configuration_passkeys_path(ri: "jp"), headers: @headers
      assert_response :forbidden
    end
  end

  # Case E-1: Unknown challenge
  test "verification fails with unknown challenge" do
    params = {
      challenge_id: "unknown",
      credential: { id: "cred_id", response: {} },
    }
    post verification_sign_app_configuration_passkeys_path(ri: "jp"), params: params, headers: @headers
    assert_response :bad_request
    # Generic error message validation
    assert_includes response.parsed_body["error"], I18n.t("errors.webauthn.challenge_invalid")
  end

  # Case E-3: Verify success
  test "verification creates passkey on success" do
    # Get challenge
    post options_sign_app_configuration_passkeys_path(ri: "jp"), headers: @headers
    challenge_id = response.parsed_body["challenge_id"]

    # Mock WebAuthn verification
    # Mock WebAuthn verification using a plain object
    mock_credential = Object.new
    mock_credential.define_singleton_method(:id) { "new_webauthn_id" }
    mock_credential.define_singleton_method(:public_key) { "new_public_key" }
    mock_credential.define_singleton_method(:sign_count) { 1 }
    mock_credential.define_singleton_method(:verify) do |*_args|
      true
    end

    WebAuthn::Credential.stub :from_create, mock_credential do
      params = {
        challenge_id: challenge_id,
        credential: {
          id: "new_webauthn_id",
          response: { clientDataJSON: "e30=", attestationObject: "e30=" },
        },
        description: "New Passkey",
      }

      assert_difference("UserPasskey.count", 1) do
        post verification_sign_app_configuration_passkeys_path(ri: "jp"), params: params, headers: @headers
      end

      assert_response :created
      assert_equal "ok", response.parsed_body["status"]
    end
  end

  # Case E-4: Verify failure
  test "verification fails on WebAuthn error" do
    # Get challenge
    post options_sign_app_configuration_passkeys_path(ri: "jp"), headers: @headers
    challenge_id = response.parsed_body["challenge_id"]

    # Mock WebAuthn failure using a plain object
    mock_credential = Object.new
    # Define dummy signature to accept any args
    mock_credential.define_singleton_method(:verify) do |*_args|
      raise WebAuthn::Error, "Verification failed"
    end

    WebAuthn::Credential.stub :from_create, mock_credential do
      params = {
        challenge_id: challenge_id,
        credential: { id: "id", response: {} },
      }

      assert_no_difference("UserPasskey.count") do
        post verification_sign_app_configuration_passkeys_path(ri: "jp"), params: params, headers: @headers
      end

      assert_response :unprocessable_content
    end
  end

  # Standard CRUD tests retained and updated to avoid conflicts or use as is
  test "should get index" do
    get sign_app_configuration_passkeys_path(ri: "jp"), headers: @headers
    assert_response :ok
  end

  test "should get new" do
    get new_sign_app_configuration_passkey_path(ri: "jp"), headers: @headers
    assert_response :ok
  end

  private

  def regional_defaults
    { ri: "jp" }
  end
end
