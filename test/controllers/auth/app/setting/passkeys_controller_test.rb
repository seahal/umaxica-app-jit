# frozen_string_literal: true

require "test_helper"
require "minitest/mock"

class Auth::App::Setting::PasskeysControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @headers = { "X-TEST-CURRENT-USER" => @user.id }.freeze
  end

  test "should get challenge" do
    # Mocking WebAuthn::Credential.options_for_create
    stub_options = OpenStruct.new(challenge: "mock_challenge")

    WebAuthn::Credential.stub :options_for_create, stub_options do
      post challenge_auth_app_setting_passkeys_url, headers: @headers
    end

    assert_response :ok
    assert_not_nil session[:webauthn_user_create_challenge]
    assert_equal "mock_challenge", session[:webauthn_user_create_challenge]
  end

  test "should verify passkey" do
    # First set the session challenge
    stub_options = OpenStruct.new(challenge: "mock_challenge")
    WebAuthn::Credential.stub :options_for_create, stub_options do
      post challenge_auth_app_setting_passkeys_url, headers: @headers
    end

    # Now verify
    credential = OpenStruct.new(id: "credential-id", public_key: "pk", sign_count: 0)
    def credential.verify(_challenge)
      true
    end

    WebAuthn::Credential.stub :from_create, credential do
      post verify_auth_app_setting_passkeys_url,
           params: { credential: { id: "credential-id", rawId: "credential-id" }, description: "Test" },
           headers: @headers
    end

    assert_response :ok
  end

  test "should get index" do
    get auth_app_setting_passkeys_url, headers: @headers

    assert_response :ok
  end

  test "should get new" do
    get new_auth_app_setting_passkey_url, headers: @headers

    assert_response :ok
  end

  test "should show passkey" do
    passkey = UserIdentityPasskey.create!(
      user: @user,
      description: "Show Me",
      public_key: "pk",
      external_id: SecureRandom.uuid,
      webauthn_id: SecureRandom.uuid,
      sign_count: 0,
    )

    get auth_app_setting_passkey_url(passkey), headers: @headers

    assert_response :ok
  end

  test "should get edit" do
    passkey = UserIdentityPasskey.create!(
      user: @user,
      description: "Edit Me",
      public_key: "pk",
      external_id: SecureRandom.uuid,
      webauthn_id: SecureRandom.uuid,
      sign_count: 0,
    )

    get edit_auth_app_setting_passkey_url(passkey), headers: @headers

    assert_response :ok
  end

  test "should create passkey" do
    assert_difference("UserIdentityPasskey.count") do
      post auth_app_setting_passkeys_url, params: {
        passkey: {
          description: "My Passkey",
          public_key: "dummy_public_key",
          external_id: SecureRandom.uuid,
          webauthn_id: SecureRandom.uuid,
          sign_count: 0,
        },
      }, headers: @headers
    end

    assert_redirected_to auth_app_setting_passkey_url(UserIdentityPasskey.last, regional_defaults)
  end

  test "should update passkey" do
    passkey = UserIdentityPasskey.create!(
      user: @user,
      description: "Old Name",
      public_key: "pk",
      external_id: SecureRandom.uuid,
      webauthn_id: SecureRandom.uuid,
      sign_count: 0,
    )

    patch auth_app_setting_passkey_url(passkey), params: {
      passkey: { description: "New Name" },
    }, headers: @headers

    assert_redirected_to auth_app_setting_passkey_url(passkey, regional_defaults)
    assert_equal "New Name", passkey.reload.description
  end

  test "should destroy passkey" do
    passkey = UserIdentityPasskey.create!(
      user: @user,
      description: "Delete Me",
      public_key: "pk",
      external_id: SecureRandom.uuid,
      webauthn_id: SecureRandom.uuid,
      sign_count: 0,
    )

    assert_difference("UserIdentityPasskey.count", -1) do
      delete auth_app_setting_passkey_url(passkey), headers: @headers
    end
    assert_redirected_to auth_app_setting_passkeys_url(regional_defaults)
  end

  private

  def regional_defaults
    PreferenceConstants::DEFAULT_PREFERENCES.transform_keys(&:to_sym)
  end
end
