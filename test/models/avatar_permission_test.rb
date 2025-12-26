require "test_helper"

class AvatarPermissionTest < ActiveSupport::TestCase
  test "validations" do
    perm = AvatarPermission.new
    assert_not perm.valid?
  end
end
