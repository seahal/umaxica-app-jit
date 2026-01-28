# frozen_string_literal: true

require "test_helper"

class Sign::App::Configuration::SecretsControllerTest < ActionDispatch::IntegrationTest
  setup do
    host! ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
    @user = User.create!
    @user_secret = UserSecret.create!(
      user: @user,
      name: "Test Secret",
      password_digest: "test_password_digest",
      last_used_at: Time.zone.now,
      user_secret_kind_id: UserSecretKind::UNLIMITED,
    )
  end

  def authenticated_headers
    { "X-TEST-CURRENT-USER" => @user.id.to_s }
  end

  test "should get index" do
    get sign_app_configuration_secrets_url(ri: "jp"), headers: authenticated_headers

    assert_response :success
  end

  test "should get show" do
    get sign_app_configuration_secret_url(@user_secret, ri: "jp"), headers: authenticated_headers

    assert_response :success
  end

  test "should get new" do
    get new_sign_app_configuration_secret_url(ri: "jp"), headers: authenticated_headers

    assert_response :success
  end

  test "should get edit" do
    get edit_sign_app_configuration_secret_url(@user_secret, ri: "jp"), headers: authenticated_headers

    assert_response :success
  end

  test "should get destroy" do
    delete sign_app_configuration_secret_url(@user_secret, ri: "jp"), headers: authenticated_headers

    assert_redirected_to sign_app_configuration_secrets_path(ri: "jp")
  end

  # Security tests: Acknowledgement requirement
  test "create without acknowledgement should fail and not create secret" do
    get new_sign_app_configuration_secret_url(ri: "jp"), headers: authenticated_headers

    assert_no_difference "UserSecret.count" do
      post sign_app_configuration_secrets_url(ri: "jp"),
           params: { user_secret: { name: "Hacker" }, acknowledged: "0" },
           headers: authenticated_headers
    end

    assert_response :unprocessable_entity
    assert_select "li", text: /シークレットを控えたことを確認してください/
  end

  test "create with acknowledgement should succeed" do
    get new_sign_app_configuration_secret_url(ri: "jp"), headers: authenticated_headers

    assert_difference "UserSecret.count", 1 do
      post sign_app_configuration_secrets_url(ri: "jp"),
           params: { acknowledged: "1" },
           headers: authenticated_headers
    end

    assert_redirected_to sign_app_configuration_secrets_path(ri: "jp")
    get response.location, headers: authenticated_headers
    assert_response :success

    # Verify the secret was created with correct attributes
    created_secret = UserSecret.order(created_at: :asc).last
    assert_equal @user.id, created_secret.user_id
    assert_equal UserSecretKind::UNLIMITED, created_secret.user_secret_kind_id
    assert_equal "ACTIVE", created_secret.user_secret_status_id
  end

  # Security tests: Params are ignored
  test "create ignores user-supplied name param" do
    get new_sign_app_configuration_secret_url(ri: "jp"), headers: authenticated_headers

    post sign_app_configuration_secrets_url(ri: "jp"),
         params: { user_secret: { name: "HACKER_NAME" }, acknowledged: "1" },
         headers: authenticated_headers

    created_secret = UserSecret.order(created_at: :asc).last
    assert_not_equal "HACKER_NAME", created_secret.name
    # Name should be the prefix (first 4 chars) of the generated secret
    assert_equal 4, created_secret.name.length
  end

  test "create ignores user-supplied user_secret_kind_id param" do
    get new_sign_app_configuration_secret_url(ri: "jp"), headers: authenticated_headers

    post sign_app_configuration_secrets_url(ri: "jp"),
         params: { user_secret: { user_secret_kind_id: "ONE_TIME" }, acknowledged: "1" },
         headers: authenticated_headers

    created_secret = UserSecret.order(created_at: :asc).last
    # Should always be UNLIMITED, not ONE_TIME
    assert_equal UserSecretKind::UNLIMITED, created_secret.user_secret_kind_id
  end

  test "create ignores user-supplied enabled param" do
    get new_sign_app_configuration_secret_url(ri: "jp"), headers: authenticated_headers

    post sign_app_configuration_secrets_url(ri: "jp"),
         params: { user_secret: { enabled: "0" }, acknowledged: "1" },
         headers: authenticated_headers

    created_secret = UserSecret.order(created_at: :asc).last
    # Should always be ACTIVE, not REVOKED
    assert_equal "ACTIVE", created_secret.user_secret_status_id
  end

  # Session-based secret display test
  test "create success stores raw_secret in session for one-time display" do
    get new_sign_app_configuration_secret_url(ri: "jp"), headers: authenticated_headers

    post sign_app_configuration_secrets_url(ri: "jp"),
         params: { acknowledged: "1" },
         headers: authenticated_headers

    assert_redirected_to sign_app_configuration_secrets_path(ri: "jp")

    # Session should contain the last issued secret
    assert_not_nil session[:last_issued_secret]
    assert_not_nil session[:last_issued_secret][:prefix]
    assert_not_nil session[:last_issued_secret][:raw_secret]

    assert_not_nil session[:last_issued_secret][:raw_secret]
    prefix = session[:last_issued_secret][:prefix]

    # Follow redirect and verify secret is displayed
    get response.location, headers: authenticated_headers
    assert_response :success
    assert_match prefix, response.body

    # After rendering, session should be cleared
    get sign_app_configuration_secrets_url(ri: "jp"), headers: authenticated_headers
    # Session is cleared after the view renders, so we can't easily test it here
    # but the view code has `session.delete(:last_issued_secret)` which clears it
  end
end
