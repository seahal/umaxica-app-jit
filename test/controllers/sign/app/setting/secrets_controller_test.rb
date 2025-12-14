require "test_helper"

class Sign::App::Setting::SecretsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(webauthn_id: SecureRandom.hex(16))
    @user_identity_secret = UserIdentitySecret.create!(
      user: @user,
      name: "Test Secret",
      password_digest: "test_password_digest"
    )
  end

  def authenticated_headers
    { "X-TEST-CURRENT-USER" => @user.id.to_s }
  end

  test "should get index" do
    get sign_app_setting_secrets_url, headers: authenticated_headers

    assert_response :success
  end

  test "should get show" do
    get sign_app_setting_secret_url(@user_identity_secret), headers: authenticated_headers

    assert_response :success
  end

  test "should get new" do
    get new_sign_app_setting_secret_url, headers: authenticated_headers

    assert_response :success
  end

  test "should get create" do
    post sign_app_setting_secrets_url,
         params: { user_identity_secret: { name: "New Secret", value: "secret_value123" } },
         headers: authenticated_headers

    assert_response :redirect
  end

  test "should get edit" do
    get edit_sign_app_setting_secret_url(@user_identity_secret), headers: authenticated_headers

    assert_response :success
  end

  test "should get update" do
    patch sign_app_setting_secret_url(@user_identity_secret),
          params: { user_identity_secret: { name: "Updated Name" } },
          headers: authenticated_headers

    assert_response :redirect
  end

  test "should get destroy" do
    delete sign_app_setting_secret_url(@user_identity_secret), headers: authenticated_headers

    assert_response :redirect
  end
end
