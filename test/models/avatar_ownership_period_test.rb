require "test_helper"

class AvatarOwnershipPeriodTest < ActiveSupport::TestCase
  test "validations" do
    period = AvatarOwnershipPeriod.new
    assert_not period.valid?
  end
end
