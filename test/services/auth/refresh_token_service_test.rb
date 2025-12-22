require "test_helper"

# Ensures refresh token parsing/verification/rotation behavior stays consistent.
class RefreshTokenServiceTest < ActiveSupport::TestCase
  test "rotates a valid user refresh token" do
    user = users(:one)
    token = UserToken.create!(user: user)
    raw = token.rotate_refresh_token!
    old_digest = token.refresh_token_digest

    result = Auth::RefreshTokenService.call(refresh_token: raw)

    assert_equal token, result[:token]
    assert_match(/\A#{token.public_id}\./, result[:refresh_token])
    assert_not_equal raw, result[:refresh_token]
    assert_not_equal old_digest, token.reload.refresh_token_digest
  end

  test "rotates a valid staff refresh token" do
    staff = staffs(:one)
    token = StaffToken.create!(staff: staff)
    raw = token.rotate_refresh_token!

    result = Auth::RefreshTokenService.call(refresh_token: raw)

    assert_equal token, result[:token]
    assert_match(/\A#{token.public_id}\./, result[:refresh_token])
  end

  test "rejects malformed refresh token" do
    assert_raises(Auth::InvalidRefreshToken) do
      Auth::RefreshTokenService.call(refresh_token: "bad-token")
    end
  end

  test "rejects invalid verifier" do
    user = users(:one)
    token = UserToken.create!(user: user)
    token.rotate_refresh_token!

    assert_raises(Auth::InvalidRefreshToken) do
      Auth::RefreshTokenService.call(refresh_token: "#{token.public_id}.wrong")
    end
  end

  test "rejects revoked refresh token" do
    user = users(:one)
    token = UserToken.create!(user: user)
    raw = token.rotate_refresh_token!
    token.revoke!

    assert_raises(Auth::InvalidRefreshToken) do
      Auth::RefreshTokenService.call(refresh_token: raw)
    end
  end

  test "rejects expired refresh token" do
    user = users(:one)
    token = UserToken.create!(user: user)
    raw = token.rotate_refresh_token!
    token.update!(refresh_expires_at: 1.day.ago)

    assert_raises(Auth::InvalidRefreshToken) do
      Auth::RefreshTokenService.call(refresh_token: raw)
    end
  end
end
