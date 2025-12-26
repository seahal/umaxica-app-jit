require "test_helper"

class AvatarRolePermissionTest < ActiveSupport::TestCase
  test "validations" do
    arp = AvatarRolePermission.new
    assert_not arp.valid?
  end
end
