# frozen_string_literal: true

require "test_helper"
require "minitest/mock"
require "base64"

class Sign::App::Configuration::PasskeysControllerTest < ActionDispatch::IntegrationTest
  setup do
    host! ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
    @user = users(:one)
    @headers = { "X-TEST-CURRENT-USER" => @user.id }.freeze
  end

  test "should get index" do
    get sign_app_configuration_passkeys_url(ri: "jp"), headers: @headers

    assert_response :ok
  end

  test "should get new" do
    get new_sign_app_configuration_passkey_url(ri: "jp"), headers: @headers

    assert_response :ok
  end

  test "should show passkey" do
    passkey = UserPasskey.create!(
      user: @user,
      description: "Show Me",
      public_key: "pk",
      external_id: SecureRandom.uuid,
      webauthn_id: SecureRandom.uuid,
      sign_count: 0,
    )

    get sign_app_configuration_passkey_url(passkey, ri: "jp"), headers: @headers

    assert_response :ok
  end

  test "should get edit" do
    passkey = UserPasskey.create!(
      user: @user,
      description: "Edit Me",
      public_key: "pk",
      external_id: SecureRandom.uuid,
      webauthn_id: SecureRandom.uuid,
      sign_count: 0,
    )

    get edit_sign_app_configuration_passkey_url(passkey, ri: "jp"), headers: @headers

    assert_response :ok
  end

  test "should create passkey" do
    assert_difference("UserPasskey.count") do
      post sign_app_configuration_passkeys_url(ri: "jp"), params: {
        passkey: {
          description: "My Passkey",
          public_key: "dummy_public_key",
          external_id: SecureRandom.uuid,
          webauthn_id: SecureRandom.uuid,
          sign_count: 0,
        },
      }, headers: @headers
    end

    assert_redirected_to sign_app_configuration_passkey_url(UserPasskey.last, regional_defaults)
  end

  test "should update passkey" do
    passkey = UserPasskey.create!(
      user: @user,
      description: "Old Name",
      public_key: "pk",
      external_id: SecureRandom.uuid,
      webauthn_id: SecureRandom.uuid,
      sign_count: 0,
    )

    patch sign_app_configuration_passkey_url(passkey, ri: "jp"), params: {
      passkey: { description: "New Name" },
    }, headers: @headers

    assert_redirected_to sign_app_configuration_passkey_url(passkey, regional_defaults)
    assert_equal "New Name", passkey.reload.description
  end

  test "should destroy passkey" do
    passkey = UserPasskey.create!(
      user: @user,
      description: "Delete Me",
      public_key: "pk",
      external_id: SecureRandom.uuid,
      webauthn_id: SecureRandom.uuid,
      sign_count: 0,
    )

    assert_difference("UserPasskey.count", -1) do
      delete sign_app_configuration_passkey_url(passkey, ri: "jp"), headers: @headers
    end
    assert_redirected_to sign_app_configuration_passkeys_url(regional_defaults)
  end

  test "should redirect index when not logged in" do
    get sign_app_configuration_passkeys_url(ri: "jp")
    rt = Base64.strict_encode64(sign_app_configuration_passkeys_url(ri: "jp"))
    assert_redirected_to new_sign_app_in_url(rt: rt, host: "sign.app.localhost")
  end

  private

  def regional_defaults
    { ri: "jp" }
  end
end
