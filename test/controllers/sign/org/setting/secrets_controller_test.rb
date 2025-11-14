require "test_helper"

class Sign::Org::Setting::SecretsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @staff = Staff.create!(
      webauthn_id: SecureRandom.hex(16),
      password_digest: BCrypt::Password.create("password")
    )
    @staff_identity_secret = StaffIdentitySecret.create!(
      staff: @staff,
      password_digest: "test_password_digest"
    )
  end

  test "should get index" do
    get sign_org_setting_secrets_url

    assert_response :success
  end

  test "should get show" do
    get sign_org_setting_secret_url(@staff_identity_secret)

    assert_response :success
  end

  test "should get new" do
    get new_sign_org_setting_secret_url

    assert_response :success
  end

  test "should get create" do
    post sign_org_setting_secrets_url, params: { staff_identity_secret: { staff_id: 1, password_digest: "new_password_digest" } }

    assert_response :success
  end

  test "should get edit" do
    get edit_sign_org_setting_secret_url(@staff_identity_secret)

    assert_response :success
  end

  test "should get update" do
    patch sign_org_setting_secret_url(@staff_identity_secret), params: { staff_identity_secret: { password_digest: "updated_password_digest" } }

    assert_response :success
  end

  test "should get destroy" do
    delete sign_org_setting_secret_url(@staff_identity_secret)

    assert_response :success
  end
end
