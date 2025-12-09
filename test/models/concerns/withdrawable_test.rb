require "test_helper"

class WithdrawableConcernTest < ActiveSupport::TestCase
  test "recovery and permanent deletion boundary at exactly 30 days" do
    user = users(:one)

    # set withdrawn_at exactly 30 days ago
    user.update!(withdrawn_at: 30.days.ago)

    # At exactly the deadline: can_recover? should be false, permanently_deletable? should be true
    assert_not user.can_recover?, "User should not be able to recover at exact boundary"
    assert_predicate user, :permanently_deletable?
  end

  test "withdrawable methods available on user" do
    user = users(:one)

    assert_respond_to user, :withdrawn?
    assert_respond_to user, :active?
    assert_respond_to user, :recovery_deadline
  end

  test "withdrawable methods available on staff" do
    staff = Staff.create!(public_id: SecureRandom.uuid)

    assert_respond_to staff, :withdrawn?
    assert_respond_to staff, :active?
    assert_respond_to staff, :recovery_deadline
  end
end
