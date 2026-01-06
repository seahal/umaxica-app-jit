# frozen_string_literal: true

require "test_helper"

class Sign::App::Configuration::SecretsControllerTest < ActionDispatch::IntegrationTest
  setup do
    host! ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
    @user = User.create!(webauthn_id: SecureRandom.hex(16))
    @user_secret = UserSecret.create!(
      user: @user,
      name: "Test Secret",
      password_digest: "test_password_digest",
      last_used_at: Time.zone.now,
    )
  end

  def authenticated_headers
    { "X-TEST-CURRENT-USER" => @user.id.to_s }
  end

  test "should get index" do
    get sign_app_configuration_secrets_url, headers: authenticated_headers

    assert_response :success
  end

  test "should get show" do
    get sign_app_configuration_secret_url(@user_secret), headers: authenticated_headers

    assert_response :success
  end

  test "should get new" do
    get new_sign_app_configuration_secret_url, headers: authenticated_headers

    assert_response :success
  end

  test "should get edit" do
    get edit_sign_app_configuration_secret_url(@user_secret), headers: authenticated_headers

    assert_response :success
  end

  test "should get destroy" do
    delete sign_app_configuration_secret_url(@user_secret), headers: authenticated_headers

    assert_response :unprocessable_content
  end
end
