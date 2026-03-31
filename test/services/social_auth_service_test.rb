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
end
