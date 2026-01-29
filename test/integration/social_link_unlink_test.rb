# frozen_string_literal: true

require "test_helper"

class SocialLinkUnlinkTest < ActionDispatch::IntegrationTest
  setup do
    OmniAuth.config.test_mode = true
    @host = ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
    host! @host
    @user = users(:one) # Assumes users(:one) exists and has some login method (e.g. password/secret)
    # Ensure @user has at least one auth method to start (e.g. password secret)
    # Check fixtures or add one.
    # Note: UserSecretKind should be seeded. If validation fails, check seeded values.
    # Assuming 'password' is valid id.
    secret_kind = UserSecretKind.find_by(id: "password") || UserSecretKind.create!(id: "password")
    UserSecret.create!(user: @user, user_secret_kind_id: secret_kind.id, password_digest: "digest", name: "default")

    # Login as user
    @headers = as_user_headers(@user, host: @host)
  end

  test "should unlink apple account when another identity exists" do
    # Create Apple identity directly (link flow is handled elsewhere)
    UserSocialApple.create!(
      user: @user, uid: "apple_uid_link", provider: "apple",
      email: "link@example.com", token: "t", expires_at: 1.hour.from_now.to_i,
    )

    delete sign_app_configuration_apple_url(ri: "jp"), headers: @headers
    assert_redirected_to sign_app_configuration_apple_url(ri: "jp")
    follow_redirect!(headers: @headers)
    assert_equal I18n.t("sign.app.social.sessions.destroy.success", provider: "Apple"), flash[:notice]

    revoked = UserSocialApple.find_by(uid: "apple_uid_link")
    assert revoked
    assert_equal "REVOKED", revoked.user_identity_social_apple_status_id
  end

  test "should prevent unlinking last identity" do
    # Create user with ONLY Apple identity (remove password secret)
    @user.user_secrets.destroy_all

    UserSocialApple.create!(
      user: @user, uid: "apple_uid_solo", provider: "apple",
      email: "solo@example.com", token: "t", expires_at: 1.hour.from_now.to_i,
    )

    # Try to unlink Apple
    delete sign_app_configuration_apple_url(ri: "jp"), headers: @headers
    assert_redirected_to sign_app_configuration_apple_url(ri: "jp")
    follow_redirect!(headers: @headers)

    # Should show error
    assert_equal I18n.t("errors.social_auth.last_identity"), flash[:alert]
    assert UserSocialApple.find_by(uid: "apple_uid_solo")
  end
end
