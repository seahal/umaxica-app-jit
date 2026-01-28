# frozen_string_literal: true

require "test_helper"

class WithdrawableConcernTest < ActiveSupport::TestCase
  test "withdrawable methods available on staff" do
    staff = Staff.create!

    assert_respond_to staff, :withdrawn?
    assert_respond_to staff, :active?
    assert_respond_to staff, :recovery_deadline
    assert_respond_to staff, :can_recover?
    assert_respond_to staff, :permanently_deletable?
  end

  test "staff recovery and permanent deletion boundary at exactly 30 days" do
    staff = Staff.create!
    staff.update!(withdrawn_at: 30.days.ago)

    assert_not staff.can_recover?, "Staff should not be able to recover at exact boundary"
    assert_predicate staff, :permanently_deletable?
  end

  test "staff withdrawn? works correctly" do
    staff = Staff.create!
    staff.update!(withdrawn_at: Time.current)

    assert_predicate staff, :withdrawn?

    staff.update!(withdrawn_at: nil)

    assert_not staff.withdrawn?
  end

  test "staff active? works correctly" do
    staff = Staff.create!
    staff.update!(withdrawn_at: nil)

    assert_predicate staff, :active?

    staff.update!(withdrawn_at: Time.current)

    assert_not staff.active?
  end

  test "staff can_recover? works correctly" do
    staff = Staff.create!
    staff.update!(withdrawn_at: 15.days.ago)

    assert_predicate staff, :can_recover?

    staff.update!(withdrawn_at: 30.days.ago)

    assert_not staff.can_recover?
  end

  test "staff permanently_deletable? works correctly" do
    staff = Staff.create!
    staff.update!(withdrawn_at: 15.days.ago)

    assert_not staff.permanently_deletable?

    staff.update!(withdrawn_at: 30.days.ago)

    assert_predicate staff, :permanently_deletable?
  end

  test "withdrawn scope returns only withdrawn staff" do
    staff1 = Staff.create!
    staff2 = Staff.create!

    staff1.update!(withdrawn_at: 1.day.ago)
    staff2.update!(withdrawn_at: nil)

    withdrawn_staff = Staff.withdrawn

    assert_includes withdrawn_staff, staff1
    assert_not_includes withdrawn_staff, staff2
  end
end
