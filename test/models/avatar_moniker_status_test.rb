require "test_helper"

class AvatarMonikerStatusTest < ActiveSupport::TestCase
  test "validations" do
    status = AvatarMonikerStatus.new
    assert_not status.valid?
  end
end
