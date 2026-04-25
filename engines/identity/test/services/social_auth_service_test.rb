# typed: false
# frozen_string_literal: true

require "test_helper"

class SocialAuthServiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    # Ensure UserSocialGoogleStatus and UserSocialGoogle exist and are used correctly
    @status = UserSocialGoogleStatus.find_or_create_by!(id: UserSocialGoogleStatus::ACTIVE)
    @identity =
      UserSocialGoogle.find_or_create_by!(uid: "uid123", provider: "google") do |id|
        id.user = @user
        id.token = "token123"
        id.expires_at = 1.hour.from_now.to_i
        id.status_id = @status.id
      end

    # Add a verified email to have 2 login methods (Google + Email)
    # This ensures login_methods_remaining? returns true without stubbing
    verified_email_status =
      UserEmailStatus.find_or_create_by!(id: UserEmailStatus::VERIFIED) do |s|
        s.name = "verified"
      end
    UserEmail.create!(
      user: @user,
      address: "test-#{SecureRandom.hex(4)}@example.com",
      address_digest: "digest-#{SecureRandom.hex(8)}",
      user_email_status_id: verified_email_status.id,
      public_id: SecureRandom.alphanumeric(21),
    )

    @auth_hash = Struct.new(:provider, :uid, :credentials, :info).new(
      "google",
      "uid123",
      Struct.new(:token, :refresh_token, :expires_at).new("token123", "refresh123", 1.hour.from_now.to_i),
      Struct.new(:email).new("test@example.com"),
    )
  end

  test "handle_callback for existing google identity" do
    result = SocialAuthService.handle_callback(
      auth_hash: @auth_hash,
      current_user: nil,
      intent: "login",
    )

    assert_equal @user.id, result[:user].id
    assert_equal @identity.id, result[:identity].id
    assert_equal @user.id, result[:jwt_payload][:user_id]
  end

  test "handle_callback raises error for invalid intent" do
    assert_raises(SocialAuth::UnauthorizedError) do
      SocialAuthService.handle_callback(
        auth_hash: @auth_hash,
        current_user: nil,
        intent: "invalid",
      )
    end
  end

  test "unlink google identity" do
    # User now has 2 login methods: Google + Email (set up in setup)
    # login_methods_remaining? returns true without stubbing
    result = SocialAuthService.unlink(provider: "google", user: @user)

    assert result[:success]
    assert_equal "google", result[:provider]
    assert_equal UserSocialGoogleStatus::REVOKED, @identity.reload.status_id
  end

  test "extract_uid_from_id_token accepts forged token with allowed alg without signature verification" do
    # Documents that this method does NOT verify signatures.
    # It relies on omniauth-apple having verified the token before this point.
    # A forged token with a valid algorithm will have its sub claim extracted.
    attacker_key = OpenSSL::PKey::EC.generate("prime256v1")
    token = JWT.encode(
      { "sub" => "forged-uid-999", "iss" => "https://appleid.apple.com" },
      attacker_key, "ES256",
    )
    service = build_service_with_id_token(token)

    result = service.send(:extract_uid_from_id_token)

    assert_equal "forged-uid-999", result,
                 "extract_uid_from_id_token does not verify signatures — it depends on omniauth-apple"
  end

  test "extract_uid_from_id_token rejects id token with HMAC confusion attack" do
    hmac_token = JWT.encode(
      { "sub" => "forged-uid", "iss" => "https://appleid.apple.com" },
      "any-secret", "HS256",
    )
    service = build_service_with_id_token(hmac_token)

    assert_nil service.send(:extract_uid_from_id_token)
  end

  test "extract_uid_from_id_token rejects id token with alg none" do
    token = forge_jwt_with_header(
      { "alg" => "none" },
      { "sub" => "apple-user-123", "iss" => "https://appleid.apple.com" },
    )
    service = build_service_with_id_token(token)

    assert_nil service.send(:extract_uid_from_id_token)
  end

  test "extract_uid_from_id_token rejects id token with alg empty string" do
    token = forge_jwt_with_header(
      { "alg" => "" },
      { "sub" => "apple-user-123", "iss" => "https://appleid.apple.com" },
    )
    service = build_service_with_id_token(token)

    assert_nil service.send(:extract_uid_from_id_token)
  end

  test "extract_uid_from_id_token rejects id token with alg nil" do
    token = forge_jwt_with_header(
      { "alg" => nil },
      { "sub" => "apple-user-123", "iss" => "https://appleid.apple.com" },
    )
    service = build_service_with_id_token(token)

    assert_nil service.send(:extract_uid_from_id_token)
  end

  private

  def forge_jwt_with_header(header_hash, payload_hash)
    header = Base64.urlsafe_encode64(JSON.generate(header_hash), padding: false)
    payload = Base64.urlsafe_encode64(JSON.generate(payload_hash), padding: false)
    "#{header}.#{payload}."
  end

  def build_service_with_id_token(id_token)
    auth_hash = Struct.new(:provider, :uid, :credentials, :info).new(
      "apple",
      "apple-user-123",
      Struct.new(:token, :refresh_token, :expires_at, :id_token).new("t", "r", 1.hour.from_now.to_i, id_token),
      Struct.new(:email).new("test@example.com"),
    )
    SocialAuthService.new(auth_hash: auth_hash, current_user: nil, intent: "login")
  end
end
