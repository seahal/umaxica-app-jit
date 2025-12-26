require "test_helper"

class AvatarMembershipStatusTest < ActiveSupport::TestCase
  test "validations" do
    status = AvatarMembershipStatus.new
    assert_not status.valid?
    assert_not status.errors[:key].empty?
  end
end
