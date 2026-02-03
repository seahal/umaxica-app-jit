# frozen_string_literal: true

require "test_helper"

class Sign::App::Configuration::SecretsControllerTest < ActionDispatch::IntegrationTest
  setup do
    host! ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
    UserStatus.find_or_create_by!(id: UserStatus::NEYO)
    UserSecretStatus.find_or_create_by!(id: UserSecretStatus::ACTIVE)
    UserSecretKind.find_or_create_by!(id: UserSecretKind::LOGIN)

    @user = User.create!(
      status_id: UserStatus::NEYO,
      public_id: "secret_user_#{SecureRandom.hex(4)}",
    )
    @user_secret = UserSecret.create!(
      user: @user,
      name: "Test Secret",
      password_digest: "test_password_digest",
      last_used_at: Time.zone.now,
      user_secret_kind_id: UserSecret::Kinds::LOGIN,
    )
  end

  def authenticated_headers
    { "X-TEST-CURRENT-USER" => @user.id.to_s }
  end

  test "should get index" do
    get sign_app_configuration_secrets_url(ri: "jp"), headers: authenticated_headers

    assert_response :success
  end

  test "should show back link on index page" do
    get sign_app_configuration_secrets_url(ri: "jp"), headers: authenticated_headers

    assert_response :success
    assert_select "a[href=?]", sign_app_configuration_path(ri: "jp")
  end

  test "should get show" do
    get sign_app_configuration_secret_url(@user_secret, ri: "jp"), headers: authenticated_headers

    assert_response :success
  end

  test "should get new" do
    get new_sign_app_configuration_secret_url(ri: "jp"), headers: authenticated_headers

    assert_response :success
  end

  test "should show back link on new page" do
    get new_sign_app_configuration_secret_url(ri: "jp"), headers: authenticated_headers

    assert_response :success
    assert_select "a[href=?]", sign_app_configuration_path(ri: "jp"), text: /#{Regexp.escape(I18n.t("actions.back"))}/
  end

  test "should get edit" do
    get edit_sign_app_configuration_secret_url(@user_secret, ri: "jp"), headers: authenticated_headers

    assert_response :success
  end

  test "should show back link on edit page" do
    get edit_sign_app_configuration_secret_url(@user_secret, ri: "jp"), headers: authenticated_headers

    assert_response :success
    assert_select "a[href=?]", sign_app_configuration_path(ri: "jp"), text: /#{Regexp.escape(I18n.t("actions.back"))}/
  end

  test "should get destroy" do
    delete sign_app_configuration_secret_url(@user_secret, ri: "jp"), headers: authenticated_headers

    assert_response :unprocessable_content
  end
end
