# frozen_string_literal: true

require "test_helper"

class UserWithdrawalFlowTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::TimeHelpers

  setup do
    @user = users(:one)
    @user.update!(
      status_id: UserStatus::ACTIVE,
      withdraw_requested_at: nil,
      withdraw_scheduled_at: nil,
      withdraw_cooldown_until: nil,
    )
  end

  test "ACTIVE transitions to PRE_WITHDRAWAL_CONDITION and timestamps are set" do
    freeze_time do
      @user.request_withdrawal!
      @user.reload

      assert_equal UserStatus::PRE_WITHDRAWAL_CONDITION, @user.status_id
      assert_equal Time.current, @user.withdraw_requested_at
      assert_equal Time.current + User::WITHDRAWAL_SCHEDULE_PERIOD, @user.withdraw_scheduled_at
      assert_equal Time.current + User::WITHDRAWAL_COOLDOWN_PERIOD, @user.withdraw_cooldown_until
    end
  end

  test "cooldown prevents repeated withdrawal operations" do
    @user.update!(
      status_id: UserStatus::PRE_WITHDRAWAL_CONDITION,
      withdraw_cooldown_until: 23.hours.from_now,
    )

    assert_raises(Sign::WithdrawalCooldownError) do
      @user.request_withdrawal!
    end
  end

  test "scheduled withdrawal finalizes after 31 days" do
    @user.update!(
      status_id: UserStatus::PRE_WITHDRAWAL_CONDITION,
      withdraw_scheduled_at: 31.days.ago,
      withdraw_cooldown_until: 2.days.ago,
    )

    User.finalize_scheduled_withdrawals!(Time.current)

    assert_equal UserStatus::WITHDRAWN, @user.reload.status_id
  end

  test "login after cooldown finalizes withdrawal and revokes sessions" do
    @user.update!(
      status_id: UserStatus::PRE_WITHDRAWAL_CONDITION,
      withdraw_cooldown_until: 1.hour.ago,
      withdraw_scheduled_at: 30.days.from_now,
    )

    token = UserToken.create!(user: @user, refresh_expires_at: 1.day.from_now)

    assert_raises(Sign::WithdrawalFinalizedError) do
      @user.enforce_withdrawal_on_login!(Time.current)
    end

    assert_equal UserStatus::WITHDRAWN, @user.reload.status_id
    assert_not_nil token.reload.revoked_at
  end
end
