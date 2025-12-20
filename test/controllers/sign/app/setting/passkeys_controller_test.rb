# frozen_string_literal: true

require "test_helper"

class Sign::App::Setting::PasskeysControllerTest < ActionDispatch::IntegrationTest
  self.use_transactional_tests = false
  setup do
    @user = User.create!(public_id: "user_#{SecureRandom.hex(8)}", user_identity_status_id: "ALIVE")
    @headers = { "X-TEST-CURRENT-USER" => @user.id }.freeze
  end

  teardown do
    UserIdentityPasskey.delete_all
    @user&.destroy
  end

  test "should get challenge" do
    skip "WebAuthn not supported in test environment"
    post sign_app_setting_passkeys_challenge_url, headers: @headers

    assert_response :ok
    assert_not_nil session[:webauthn_create_challenge]
  end

  test "should create passkey" do
    assert_difference("UserIdentityPasskey.count") do
      post sign_app_setting_passkeys_url, params: {
        passkey: {
          description: "My Passkey",
          public_key: "dummy_public_key",
          external_id: SecureRandom.uuid,
          webauthn_id: SecureRandom.uuid,
          sign_count: 0
        }
      }, headers: @headers
    end

    assert_redirected_to sign_app_setting_passkey_url(UserIdentityPasskey.last, regional_defaults)
  end

  test "should update passkey" do
    passkey = UserIdentityPasskey.create!(user: @user,
                                          description: "Old Name",
                                          public_key: "pk",
                                          external_id: SecureRandom.uuid,
                                          webauthn_id: SecureRandom.uuid,
                                          sign_count: 0)

    patch sign_app_setting_passkey_url(passkey), params: {
      passkey: { description: "New Name" }
    }, headers: @headers

    assert_redirected_to sign_app_setting_passkey_url(passkey, regional_defaults)
    assert_equal "New Name", passkey.reload.description
  end

  test "should destroy passkey" do
    passkey = UserIdentityPasskey.create!(user: @user,
                                          description: "Delete Me",
                                          public_key: "pk",
                                          external_id: SecureRandom.uuid,
                                          webauthn_id: SecureRandom.uuid,
                                          sign_count: 0)

    assert_difference("UserIdentityPasskey.count", -1) do
      delete sign_app_setting_passkey_url(passkey), headers: @headers
    end
    assert_redirected_to sign_app_setting_passkeys_url(regional_defaults)
  end

  private

  def regional_defaults
    PreferenceConstants::DEFAULT_PREFERENCES.transform_keys(&:to_sym)
  end
end
