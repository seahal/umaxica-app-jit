# frozen_string_literal: true

require "test_helper"
require "minitest/mock"

class Sign::App::Configuration::PasskeysControllerTest < ActionDispatch::IntegrationTest
  setup do
    host! ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
    @user = users(:one)
    @headers = { "X-TEST-CURRENT-USER" => @user.id }.freeze

    # Cleanup potentially corrupted UserEmails
    UserEmail.delete_all

    # Mock TRUSTED_ORIGINS
    allowed_origins = [
      "http://sign.app.localhost",
      "http://sign.org.localhost",
      "http://www.example.com",
      "http://#{ENV.fetch("SIGN_SERVICE_URL", "sign.umaxica.app")}",
      "https://#{ENV.fetch("SIGN_SERVICE_URL", "sign.umaxica.app")}"
    ].uniq

    # Store original implementation
    @original_trusted_origins_impl = Webauthn.singleton_class.instance_method(:trusted_origins) rescue nil

    # Override with test origins (use local variable to ensure it's captured in closure)
    Webauthn.define_singleton_method(:trusted_origins) { allowed_origins }
  end

  teardown do
    # Restore original implementation if it existed
    if @original_trusted_origins_impl
      Webauthn.define_singleton_method(:trusted_origins, @original_trusted_origins_impl)
    end
  end

  # Case D-1: Not logged in
  test "options redirects when not logged in" do
    post options_sign_app_configuration_passkeys_path(ri: "jp")
    assert_response :unauthorized
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
      credential: { id: "cred_id", response: {} }
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

    # Mock from_create to accept relying_party parameter
    WebAuthn::Credential.stub :from_create, ->(_credential_hash, relying_party: nil) { mock_credential } do
      params = {
        challenge_id: challenge_id,
        credential: {
          id: "new_webauthn_id",
          response: { clientDataJSON: "e30=", attestationObject: "e30=" }
        },
        description: "New Passkey"
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

    # Mock from_create to accept relying_party parameter
    WebAuthn::Credential.stub :from_create, ->(_credential_hash, relying_party: nil) { mock_credential } do
      params = {
        challenge_id: challenge_id,
        credential: { id: "id", response: {} }
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

  # Test relying_party is correctly passed
  test "verification passes relying_party to from_create" do
    post options_sign_app_configuration_passkeys_path(ri: "jp"), headers: @headers
    challenge_id = response.parsed_body["challenge_id"]

    mock_credential = Object.new
    mock_credential.define_singleton_method(:id) { "webauthn_id_with_rp" }
    mock_credential.define_singleton_method(:public_key) { "public_key_with_rp" }
    mock_credential.define_singleton_method(:sign_count) { 1 }
    mock_credential.define_singleton_method(:verify) { |*_args| true }

    # Verify relying_party is passed
    relying_party_received = nil
    mock_from_create = lambda do |_credential_hash, relying_party: nil|
      relying_party_received = relying_party
      mock_credential
    end

    WebAuthn::Credential.stub :from_create, mock_from_create do
      params = {
        challenge_id: challenge_id,
        credential: {
          id: "webauthn_id_with_rp",
          response: { clientDataJSON: "e30=", attestationObject: "e30=" }
        },
        description: "Passkey with RP"
      }

      post verification_sign_app_configuration_passkeys_path(ri: "jp"), params: params, headers: @headers

      assert_response :created
      assert_not_nil relying_party_received, "relying_party should be passed to from_create"
      assert_instance_of WebAuthn::RelyingParty, relying_party_received
      assert_includes relying_party_received.allowed_origins, "http://sign.app.localhost"
      assert_equal "sign.app.localhost", relying_party_received.id
    end
  end

  # Test multiple passkeys can be registered
  test "user can register multiple passkeys up to limit" do
    # Clean up existing passkeys for user
    @user.user_passkeys.destroy_all

    3.times do |i|
      post options_sign_app_configuration_passkeys_path(ri: "jp"), headers: @headers
      challenge_id = response.parsed_body["challenge_id"]

      mock_credential = Object.new
      mock_credential.define_singleton_method(:id) { "webauthn_id_#{i}" }
      mock_credential.define_singleton_method(:public_key) { "public_key_#{i}" }
      mock_credential.define_singleton_method(:sign_count) { 1 }
      mock_credential.define_singleton_method(:verify) { |*_args| true }

      WebAuthn::Credential.stub :from_create, ->(_credential_hash, relying_party: nil) { mock_credential } do
        params = {
          challenge_id: challenge_id,
          credential: {
            id: "webauthn_id_#{i}",
            response: { clientDataJSON: "e30=", attestationObject: "e30=" }
          },
          description: "Passkey #{i + 1}"
        }

        post verification_sign_app_configuration_passkeys_path(ri: "jp"), params: params, headers: @headers
        assert_response :created
      end
    end

    assert_equal 3, @user.user_passkeys.count
  end

  # Test passkey can be deleted
  test "user can delete their passkey" do
    # Create a passkey for the user
    passkey = UserPasskey.create!(
      user: @user,
      webauthn_id: "deletable_webauthn_id",
      public_key: "deletable_public_key",
      sign_count: 1,
      description: "Deletable Passkey"
    )

    assert_difference("UserPasskey.count", -1) do
      delete sign_app_configuration_passkey_path(passkey, ri: "jp"), headers: @headers
    end

    assert_response :see_other
  end

  # Test passkey description can be updated
  test "user can update passkey description" do
    passkey = UserPasskey.create!(
      user: @user,
      webauthn_id: "updatable_webauthn_id",
      public_key: "updatable_public_key",
      sign_count: 1,
      description: "Old Description"
    )

    patch sign_app_configuration_passkey_path(passkey, ri: "jp"),
          params: { passkey: { description: "New Description" } },
          headers: @headers

    assert_response :redirect
    assert_redirected_to sign_app_configuration_passkeys_path(ri: "jp")
    passkey.reload
    assert_equal "New Description", passkey.description
  end

  # Test user can view edit page
  test "user can get edit page for their passkey" do
    passkey = UserPasskey.create!(
      user: @user,
      webauthn_id: "editable_webauthn_id",
      public_key: "editable_public_key",
      sign_count: 1,
      description: "Test Passkey"
    )

    get edit_sign_app_configuration_passkey_path(passkey, ri: "jp"), headers: @headers

    assert_response :ok
    assert_includes response.body, "Test Passkey"
    assert_includes response.body, "passkey[description]"
  end

  # Test user cannot edit another user's passkey
  test "user cannot edit another user's passkey" do
    other_user = users(:two)
    passkey = UserPasskey.create!(
      user: other_user,
      webauthn_id: "other_user_webauthn_id",
      public_key: "other_user_public_key",
      sign_count: 1,
      description: "Other User's Passkey"
    )

    # Controller scopes to current_user.user_passkeys and uses find_by! with public_id
    get edit_sign_app_configuration_passkey_path(passkey, ri: "jp"), headers: @headers

    # Should return 404 or redirect (depending on error handling)
    assert_response :not_found
  end

  # Test update with empty description sets default
  test "update with empty description sets default" do
    passkey = UserPasskey.create!(
      user: @user,
      webauthn_id: "invalid_update_webauthn_id",
      public_key: "invalid_update_public_key",
      sign_count: 1,
      description: "Valid Description"
    )

    patch sign_app_configuration_passkey_path(passkey, ri: "jp"),
          params: { passkey: { description: "" } },
          headers: @headers

    assert_response :redirect
    assert_redirected_to sign_app_configuration_passkeys_path(ri: "jp")
    # Model sets default description when blank via before_validation
    passkey.reload
    assert_equal I18n.t("sign.default_passkey_description"), passkey.description
  end

  private

    def regional_defaults
      { ri: "jp" }
    end
end
