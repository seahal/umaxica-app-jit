# frozen_string_literal: true

require "test_helper"

class SocialAuthServiceTest < ActiveSupport::TestCase
  fixtures :user_statuses, :user_social_google_statuses, :user_social_apple_statuses

  test "social login assigns user status during user creation" do
    auth_hash = OmniAuth::AuthHash.new(
      provider: "google_oauth2",
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
end
