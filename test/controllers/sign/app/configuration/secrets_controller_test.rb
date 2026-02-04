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

  test "should create secret and redirect to index" do
    assert_difference("UserSecret.count", 1) do
      post sign_app_configuration_secrets_url(ri: "jp"),
           params: { user_secret: { name: "New Secret", enabled: true } },
           headers: authenticated_headers
    end

    assert_redirected_to sign_app_configuration_secrets_url(ri: "jp")
    assert_predicate flash[:raw_secret], :present?
  end

  test "should update secret and redirect to index" do
    patch sign_app_configuration_secret_url(@user_secret, ri: "jp"),
          params: { user_secret: { name: "Updated Secret", enabled: false } },
          headers: authenticated_headers

    assert_redirected_to sign_app_configuration_secrets_url(ri: "jp")
    @user_secret.reload
    assert_equal "Updated Secret", @user_secret.name
  end

  test "should get destroy" do
    delete sign_app_configuration_secret_url(@user_secret, ri: "jp"), headers: authenticated_headers

    assert_response :unprocessable_content
  end

  test "URL uses public_id not numeric ID" do
    get sign_app_configuration_secret_url(@user_secret, ri: "jp"), headers: authenticated_headers

    assert_response :success
    # Verify URL contains public_id, not numeric ID
    assert_not_includes request.fullpath, "/#{@user_secret.id}/"
    assert_includes request.fullpath, "/#{@user_secret.public_id}/"
  end

  test "should access secret by public_id" do
    get sign_app_configuration_secret_url(@user_secret.public_id, ri: "jp"), headers: authenticated_headers

    assert_response :success
  end

  test "should not access secret by numeric ID" do
    assert_raises(ActiveRecord::RecordNotFound) do
      get sign_app_configuration_secret_url(@user_secret.id, ri: "jp"), headers: authenticated_headers
    end
  end
end
