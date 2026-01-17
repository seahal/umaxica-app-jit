# frozen_string_literal: true

require "test_helper"

class Sign::RefreshTokenServiceTest < ActiveSupport::TestCase
  fixtures :users, :user_tokens

  test "rotation increments generation counter" do
    token = UserToken.create!(user: users(:one))
    first_refresh = token.rotate_refresh_token!
    result = Sign::RefreshTokenService.call(refresh_token: first_refresh)

    token.reload
    second_generation = token.refresh_token_generation

    assert_equal 2, second_generation
    assert_kind_of Hash, result
    assert_equal token, result[:token]
  end

  test "reuse detection revokes all actor tokens" do
    user = users(:one)
    token = UserToken.create!(user: user)
    initial_refresh = token.rotate_refresh_token!
    rotated = Sign::RefreshTokenService.call(refresh_token: initial_refresh)
    rotated_refresh = rotated[:refresh_token]

    assert_raises(Sign::InvalidRefreshToken) do
      Sign::RefreshTokenService.call(refresh_token: initial_refresh)
    end

    token.reload
    assert token.revoked_at, "Original token should be revoked"
    assert token.compromised_at, "Compromise timestamp should be recorded"
    assert UserToken.where(user_id: user.id).all?(&:revoked?), "All actor tokens should be revoked"

    assert_raises(Sign::InvalidRefreshToken) do
      Sign::RefreshTokenService.call(refresh_token: rotated_refresh)
    end
  end

  test "revoked tokens stay invalid without marking compromise" do
    token = user_tokens(:one)
    refresh = token.rotate_refresh_token!
    token.revoke!

    assert_raises(Sign::InvalidRefreshToken) do
      Sign::RefreshTokenService.call(refresh_token: refresh)
    end

    assert_nil token.reload.compromised_at
  end
end
