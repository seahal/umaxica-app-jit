# frozen_string_literal: true

require "test_helper"

class TokenEmergencyServiceTest < ActiveSupport::TestCase
  fixtures :users, :user_statuses, :user_token_statuses, :user_token_kinds

  setup do
    @user = users(:one)
    UserToken.where(user_id: @user.id).delete_all
  end

  test "raises error for invalid action" do
    error =
      assert_raises(TokenEmergencyService::EmergencyActionError) do
        TokenEmergencyService.call!(action: "invalid", surface: "app", actor_id: @user.id, reason: "test")
      end
    assert_includes error.message, "Invalid action"
  end

  test "raises error for invalid surface" do
    error =
      assert_raises(TokenEmergencyService::EmergencyActionError) do
        TokenEmergencyService.call!(action: "access_reset", surface: "invalid", actor_id: @user.id, reason: "test")
      end
    assert_includes error.message, "Invalid surface"
  end

  test "perform_access_reset revokes all active tokens" do
    token = UserToken.create!(user: @user, refresh_expires_at: 1.day.from_now)

    result = TokenEmergencyService.call!(
      action: "access_reset",
      surface: "app",
      actor_id: @user.id,
      reason: "security incident",
    )

    assert_equal 1, result[:affected_count]
    assert_equal "access_reset", result[:action]

    token.reload
    assert_not_nil token.revoked_at
  end

  test "perform_revoke_all revokes all tokens including revoked" do
    token1 = UserToken.create!(user: @user, refresh_expires_at: 1.day.from_now)
    token2 = UserToken.create!(user: @user, refresh_expires_at: 1.day.from_now, revoked_at: 1.hour.ago)

    result = TokenEmergencyService.call!(
      action: "revoke_all",
      surface: "app",
      actor_id: @user.id,
      reason: "account compromised",
    )

    assert_equal 2, result[:affected_count]

    token1.reload
    token2.reload
    assert_not_nil token1.revoked_at
    assert_not_nil token2.revoked_at
  end

  test "perform_refresh_freeze sets refresh_expires_at to now" do
    token = UserToken.create!(user: @user, refresh_expires_at: 30.days.from_now)

    result = TokenEmergencyService.call!(
      action: "refresh_freeze",
      surface: "app",
      actor_id: @user.id,
      reason: "suspicious activity",
    )

    assert_equal 1, result[:affected_count]

    token.reload
    assert_operator token.refresh_expires_at, :<=, Time.current
  end

  test "perform_refresh_unfreeze extends refresh_expires_at" do
    token = UserToken.create!(user: @user, refresh_expires_at: Time.current)

    result = TokenEmergencyService.call!(
      action: "refresh_unfreeze",
      surface: "app",
      actor_id: @user.id,
      reason: "false alarm",
    )

    assert_equal 1, result[:affected_count]
    assert_not_nil result[:new_expiry]

    token.reload
    assert_operator token.refresh_expires_at, :>, Time.current
  end

  test "returns zero affected count when no tokens exist" do
    result = TokenEmergencyService.call!(
      action: "access_reset",
      surface: "app",
      actor_id: @user.id,
      reason: "test",
    )

    assert_equal 0, result[:affected_count]
  end

  test "access_reset does not affect already-revoked tokens" do
    revoked_token = UserToken.create!(user: @user, refresh_expires_at: 1.day.from_now, revoked_at: 1.hour.ago)

    result = TokenEmergencyService.call!(
      action: "access_reset",
      surface: "app",
      actor_id: @user.id,
      reason: "test",
    )

    assert_equal 0, result[:affected_count]
    revoked_token.reload
    # revoked_at should remain the original value, not be overwritten
    assert_in_delta 1.hour.ago, revoked_token.revoked_at, 5.seconds
  end

  test "perform_refresh_unfreeze result includes new_expiry close to 30 days from now" do
    UserToken.create!(user: @user, refresh_expires_at: Time.current)

    result = TokenEmergencyService.call!(
      action: "refresh_unfreeze",
      surface: "app",
      actor_id: @user.id,
      reason: "test",
    )

    expected = TokenEmergencyService::REFRESH_UNFREEZE_EXPIRY.from_now
    assert_in_delta expected, result[:new_expiry], 5.seconds
  end

  # ---------------------------------------------------------------------------
  # TOKEN_FOREIGN_KEYS / resource_foreign_key guard
  # ---------------------------------------------------------------------------

  test "resource_foreign_key raises for unknown token class" do
    assert_raises(TokenEmergencyService::EmergencyActionError) do
      TokenEmergencyService.send(:resource_foreign_key, String)
    end
  end

  # ---------------------------------------------------------------------------
  # private_class_method guards
  # ---------------------------------------------------------------------------

  test "perform_action is not publicly callable" do
    assert_raises(NoMethodError) do
      TokenEmergencyService.perform_action("access_reset", UserToken, @user.id)
    end
  end

  test "record_audit is not publicly callable" do
    assert_raises(NoMethodError) do
      TokenEmergencyService.record_audit("access_reset", "app", @user.id, "reason", { affected_count: 0 })
    end
  end
end
