# frozen_string_literal: true

require "test_helper"

class Sign::RefreshTokenServiceTest < ActiveSupport::TestCase
  fixtures :users, :user_statuses, :user_token_statuses, :user_token_kinds, :user_tokens

  setup do
    # UserToken.where(user: users(:one)).delete_all
  end

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

  test "S2: service uses writing role for lock and update operations" do
    # Verify that ActiveRecord::Base.connected_to is called with role: :writing
    # This ensures SELECT ... FOR UPDATE and UPDATE go to primary database
    original_method = ActiveRecord::Base.method(:connected_to)

    connection_calls = []
    ActiveRecord::Base.define_singleton_method(:connected_to) do |**options, &block|
      connection_calls << options
      original_method.call(**options, &block)
    end

    token = UserToken.create!(user: users(:one))
    refresh = token.rotate_refresh_token!

    Sign::RefreshTokenService.call(refresh_token: refresh)

    # Verify that connected_to was called with role: :writing
    assert connection_calls.any? { |opts| opts[:role] == :writing },
           "RefreshTokenService should use writing role for lock/update operations"
  ensure
    # Restore original method
    ActiveRecord::Base.define_singleton_method(:connected_to, original_method)
  end

  test "S2: no ReadOnlyError occurs during refresh" do
    # This test verifies that refresh operations do not trigger ReadOnlyError
    # even when using SELECT ... FOR UPDATE
    token = UserToken.create!(user: users(:one))
    refresh = token.rotate_refresh_token!

    assert_nothing_raised do
      result = Sign::RefreshTokenService.call(refresh_token: refresh)
      assert_kind_of Hash, result
      assert_equal token, result[:token]
    end
  end
end
