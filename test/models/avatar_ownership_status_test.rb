require "test_helper"

class AvatarOwnershipStatusTest < ActiveSupport::TestCase
  test "validations" do
    status = AvatarOwnershipStatus.new
    assert_not status.valid?
  end
end
