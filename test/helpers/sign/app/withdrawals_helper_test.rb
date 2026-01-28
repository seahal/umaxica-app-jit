# frozen_string_literal: true

require "test_helper"

class Sign::App::WithdrawalsHelperTest < ActionView::TestCase
  include ActiveSupport::Testing::TimeHelpers

  UserStub =
    Struct.new(:pre_withdrawal, :withdrawn, :withdraw_scheduled_at) do
      def pre_withdrawal_condition?
        pre_withdrawal
      end

      def withdrawn?
        withdrawn
      end
    end

  setup do
    extend Sign::App::WithdrawalsHelper
  end

  def current_user
    @current_user
  end

  test "user_withdrawn? returns true when user is withdrawn" do
    @current_user = UserStub.new(false, true, nil)

    assert_predicate self, :user_withdrawn?
  end

  test "user_withdrawn? returns false when user not withdrawn" do
    @current_user = UserStub.new(false, false, nil)

    assert_not_predicate self, :user_withdrawn?
  end

  test "user_withdrawn? returns true when user is pre-withdrawal" do
    @current_user = UserStub.new(true, false, 1.day.from_now)

    assert_predicate self, :user_withdrawn?
  end

  test "user_withdrawn? returns false without current user" do
    @current_user = nil

    assert_not_predicate self, :user_withdrawn?
  end

  test "days_until_permanent_deletion returns nil when not withdrawn" do
    @current_user = UserStub.new(false, false, nil)

    assert_nil days_until_permanent_deletion
  end

  test "days_until_permanent_deletion returns 0 when deadline has passed" do
    @current_user = UserStub.new(true, false, 1.day.ago)

    assert_equal 0, days_until_permanent_deletion
  end

  test "days_until_permanent_deletion returns 0 when deadline missing" do
    @current_user = UserStub.new(true, false, nil)

    assert_equal 0, days_until_permanent_deletion
  end

  test "days_until_permanent_deletion rounds up remaining days" do
    @current_user = UserStub.new(true, false, nil)

    travel_to Time.zone.parse("2024-01-01 00:00:00") do
      @current_user.withdraw_scheduled_at = Time.zone.parse("2024-01-03 12:00:00")

      assert_equal 3, days_until_permanent_deletion
    end
  end

  test "recovery_period_expired? returns true after deadline" do
    @current_user = UserStub.new(true, false, nil)

    travel_to Time.zone.parse("2024-01-02 00:00:00") do
      @current_user.withdraw_scheduled_at = Time.zone.parse("2024-01-01 00:00:00")

      assert_predicate self, :recovery_period_expired?
    end
  end

  test "recovery_period_expired? returns false when not withdrawn" do
    @current_user = UserStub.new(false, false, 1.day.ago)

    assert_not_predicate self, :recovery_period_expired?
  end

  test "recovery_period_expired? returns false before deadline" do
    @current_user = UserStub.new(true, false, 1.day.from_now)

    assert_not_predicate self, :recovery_period_expired?
  end

  test "recovery_period_expired? returns false when deadline is missing" do
    @current_user = UserStub.new(true, false, nil)

    assert_not_predicate self, :recovery_period_expired?
  end

  test "recovery_period_expired? returns false without current user" do
    @current_user = nil

    assert_not_predicate self, :recovery_period_expired?
  end
end
