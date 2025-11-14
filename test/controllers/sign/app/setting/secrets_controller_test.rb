require "test_helper"

class Sign::App::Setting::SecretsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(webauthn_id: SecureRandom.hex(16))
    @user_identity_secret = UserIdentitySecret.create!(
      user: @user,
      password_digest: "test_password_digest"
    )
  end

  test "should get index" do
    get sign_app_setting_secrets_url

    assert_response :success
  end

  test "should get show" do
    get sign_app_setting_secret_url(@user_identity_secret)

    assert_response :success
  end

  test "should get new" do
    get new_sign_app_setting_secret_url

    assert_response :success
  end

  test "should get create" do
    post sign_app_setting_secrets_url, params: { user_identity_secret: { user_id: 1, password_digest: "new_password_digest" } }

    assert_response :success
  end

  test "should get edit" do
    get edit_sign_app_setting_secret_url(@user_identity_secret)

    assert_response :success
  end

  test "should get update" do
    patch sign_app_setting_secret_url(@user_identity_secret), params: { user_identity_secret: { password_digest: "updated_password_digest" } }

    assert_response :success
  end

  test "should get destroy" do
    delete sign_app_setting_secret_url(@user_identity_secret)

    assert_response :success
  end
end
