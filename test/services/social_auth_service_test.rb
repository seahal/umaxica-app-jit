# typed: false
# frozen_string_literal: true

require "test_helper"

class SocialAuthServiceTest < ActiveSupport::TestCase
  fixtures :user_statuses, :user_social_google_statuses, :user_social_apple_statuses

  test "social login assigns user status during user creation" do
    auth_hash = OmniAuth::AuthHash.new(
      provider: "google_app",
      uid: "google_uid_status_test",
      credentials: {
        token: "test_token",
        expires_at: 1.week.from_now.to_i,
      },
    )

    result = SocialAuthService.handle_callback(auth_hash: auth_hash, current_user: nil, intent: "login")

    assert_equal UserStatus::UNVERIFIED_WITH_SIGN_UP, result[:user].status_id
  end

  # --- extract_uid_from_id_token fallback (Apple) ---

  test "extracts uid from Apple id_token as fallback when uid field is blank" do
    rsa_key = OpenSSL::PKey::RSA.generate(2048)
    id_token = JWT.encode({ "sub" => "apple_fallback_uid_001" }, rsa_key, "RS256")

    auth_hash = OmniAuth::AuthHash.new(
      provider: "apple",
      uid: "",
      credentials: {
        token: "apple_access_token",
        expires_at: 1.week.from_now.to_i,
        id_token: id_token,
      },
      extra: { raw_info: {}, id_info: {} },
    )

    result = SocialAuthService.handle_callback(auth_hash: auth_hash, current_user: nil, intent: "login")

    assert_equal "apple_fallback_uid_001", result[:identity].uid
  end

  test "raises ProviderError when Apple id_token uses alg:none" do
    header  = Base64.urlsafe_encode64('{"alg":"none","typ":"JWT"}', padding: false)
    payload = Base64.urlsafe_encode64('{"sub":"forged_apple_uid"}', padding: false)
    none_token = "#{header}.#{payload}."

    auth_hash = OmniAuth::AuthHash.new(
      provider: "apple",
      uid: "",
      credentials: {
        token: "apple_access_token",
        expires_at: 1.week.from_now.to_i,
        id_token: none_token,
      },
      extra: { raw_info: {}, id_info: {} },
    )

    assert_raises(SocialAuth::ProviderError) do
      SocialAuthService.handle_callback(auth_hash: auth_hash, current_user: nil, intent: "login")
    end
  end

  test "raises ProviderError when Apple id_token is malformed" do
    auth_hash = OmniAuth::AuthHash.new(
      provider: "apple",
      uid: "",
      credentials: {
        token: "apple_access_token",
        expires_at: 1.week.from_now.to_i,
        id_token: "not.a.valid.jwt",
      },
      extra: { raw_info: {}, id_info: {} },
    )

    assert_raises(SocialAuth::ProviderError) do
      SocialAuthService.handle_callback(auth_hash: auth_hash, current_user: nil, intent: "login")
    end
  end

  test "link intent associates identity with existing user" do
    auth_hash = OmniAuth::AuthHash.new(
      provider: "google_app",
      uid: "google_uid_link_test_#{SecureRandom.hex(8)}",
      credentials: {
        token: "test_token",
        expires_at: 1.week.from_now.to_i,
      },
    )

    existing_user = users(:one)

    result = SocialAuthService.handle_callback(
      auth_hash: auth_hash,
      current_user: existing_user,
      intent: "link",
    )

    assert_equal existing_user, result[:user]
    assert_equal "google_app", result[:identity].provider
  end

  test "reauth intent updates existing identity" do
    existing_user = users(:one)
    existing_identity = UserSocialGoogle.create!(
      user: existing_user,
      uid: "google_uid_reauth_test_#{SecureRandom.hex(8)}",
      provider: "google_app",
      user_identity_social_google_status_id: UserSocialGoogleStatus::ACTIVE,
      token: "old_token",
      expires_at: 1.week.from_now.to_i,
    )

    auth_hash = OmniAuth::AuthHash.new(
      provider: "google_app",
      uid: existing_identity.uid,
      credentials: {
        token: "new_test_token",
        expires_at: 1.week.from_now.to_i,
      },
    )

    result = SocialAuthService.handle_callback(
      auth_hash: auth_hash,
      current_user: existing_user,
      intent: "reauth",
    )

    assert_equal existing_user, result[:user]
    assert_equal existing_identity.id, result[:identity].id
  end

  test "raises error for invalid intent" do
    auth_hash = OmniAuth::AuthHash.new(
      provider: "google_app",
      uid: "test_uid",
      credentials: { token: "test" },
    )

    assert_raises(SocialAuth::UnauthorizedError) do
      SocialAuthService.handle_callback(
        auth_hash: auth_hash,
        current_user: nil,
        intent: "invalid_intent",
      )
    end
  end

  test "unlink raises error when removing last login method" do
    user = users(:one)
    UserSocialGoogle.create!(
      user: user,
      uid: "google_uid_unlink_test_#{SecureRandom.hex(8)}",
      provider: "google_app",
      user_identity_social_google_status_id: UserSocialGoogleStatus::ACTIVE,
      token: "test_token",
      expires_at: 1.week.from_now.to_i,
    )

    assert_raises(SocialAuth::LastIdentityError) do
      SocialAuthService.unlink(provider: "google", user: user)
    end
  end

  test "unlink returns already_unlinked when identity not found" do
    user = users(:one)

    result = SocialAuthService.unlink(provider: "google", user: user)

    assert result[:success]
    assert result[:already_unlinked]
  end
end
