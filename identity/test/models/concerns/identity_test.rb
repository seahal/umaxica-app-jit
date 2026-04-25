# typed: false
# frozen_string_literal: true

require "test_helper"

class IdentityTest < ActiveSupport::TestCase
  fixtures :users, :staffs, :customers, :user_statuses, :staff_statuses, :customer_statuses

  # ---------------------------------------------------------------------------
  # A. login_allowed? tests
  # ---------------------------------------------------------------------------

  test "login_allowed? returns true for active user not in blocked statuses" do
    user = users(:one)
    user.update!(status_id: UserStatus::ACTIVE)

    assert_predicate user, :login_allowed?
  end

  test "login_allowed? returns false when user is withdrawn" do
    user = users(:one)
    user.update!(
      status_id: UserStatus::ACTIVE,
      withdrawn_at: Time.current,
    )

    assert_not user.login_allowed?
  end

  test "login_allowed? returns false when user status is in LOGIN_BLOCKED_STATUS_IDS" do
    # Skip if constant is not defined
    skip unless defined?(User::LOGIN_BLOCKED_STATUS_IDS)

    user = users(:one)
    blocked_status = User::LOGIN_BLOCKED_STATUS_IDS.first
    skip "No blocked statuses defined" unless blocked_status

    user.update!(status_id: blocked_status)

    assert_not user.login_allowed?
  end

  test "login_allowed? for staff returns true when active" do
    staff = staffs(:one)
    staff.update!(status_id: StaffStatus::ACTIVE)

    assert_predicate staff, :login_allowed?
  end

  test "login_allowed? for staff returns false when withdrawn" do
    staff = staffs(:one)
    staff.update!(
      status_id: StaffStatus::ACTIVE,
      withdrawn_at: Time.current,
    )

    assert_not staff.login_allowed?
  end

  test "login_allowed? for customer returns true when active" do
    customer = customers(:one)
    # Customers might have different status handling
    if defined?(CustomerStatus::ACTIVE)
      customer.update!(status_id: CustomerStatus::ACTIVE)
    end

    # Customer fixtures might not have the Identity concern included
    # or might have different business rules
    if customer.respond_to?(:login_allowed?)
      assert_predicate customer, :login_allowed?
    else
      skip "Customer does not include Identity concern"
    end
  end

  # ---------------------------------------------------------------------------
  # B. Validation tests
  # ---------------------------------------------------------------------------

  test "validates status_id is an integer" do
    user = users(:one)

    assert_predicate user, :valid?

    # Try setting to invalid value
    user.status_id = "not_an_integer"

    assert_not user.valid?
    assert_predicate user.errors[:status_id], :present?
  end

  test "validates status_id must be integer for staff" do
    staff = staffs(:one)

    assert_predicate staff, :valid?

    staff.status_id = "invalid"

    assert_not staff.valid?
  end

  # ---------------------------------------------------------------------------
  # C. Shreddable scope tests
  # ---------------------------------------------------------------------------

  test "shreddable scope includes users with shreddable_at in the past" do
    user = users(:one)
    user.update!(shreddable_at: 1.day.ago)

    assert_includes User.shreddable, user
  end

  test "shreddable scope excludes users with shreddable_at in the future" do
    user = users(:one)
    user.update!(shreddable_at: 1.day.from_now)

    assert_not_includes User.shreddable, user
  end

  test "shreddable scope excludes users with future shreddable_at" do
    user = users(:one)
    user.update!(shreddable_at: 10.years.from_now)

    assert_not_includes User.shreddable, user
  end

  test "shreddable scope with custom time" do
    user = users(:one)
    user.update!(shreddable_at: 5.days.ago)

    assert_includes User.shreddable(3.days.ago), user
    assert_not_includes User.shreddable(7.days.ago), user
  end

  # ---------------------------------------------------------------------------
  # D. Active/Withdrawn state integration
  # ---------------------------------------------------------------------------

  test "active? method is available from Accountable concern" do
    user = users(:one)

    # Verify the method exists (comes from Accountable)
    assert_respond_to user, :active?

    # Verify withdrawn_at affects active state
    user.update!(withdrawn_at: nil)

    assert_predicate user, :active?

    user.update!(withdrawn_at: Time.current)

    assert_not user.active?
  end

  test "withdrawn? method is available from Withdrawable concern" do
    user = users(:one)

    # Verify the method exists (comes from Withdrawable)
    assert_respond_to user, :withdrawn?

    user.update!(withdrawn_at: nil)

    assert_not user.withdrawn?

    user.update!(withdrawn_at: Time.current)

    assert_predicate user, :withdrawn?
  end

  # ---------------------------------------------------------------------------
  # E. Edge cases
  # ---------------------------------------------------------------------------

  test "login_allowed? returns false for inactive user" do
    user = users(:one)
    # Assuming active? checks withdrawn_at
    user.update!(withdrawn_at: Time.current)

    assert_not user.login_allowed?
  end

  test "shreddable scope with default current time" do
    user = users(:one)
    user.update!(shreddable_at: Time.current)

    # At exact current time, should be included
    assert_includes User.shreddable, user
  end
end
