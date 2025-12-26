require "test_helper"

class AvatarRoleTest < ActiveSupport::TestCase
  test "validations" do
    role = AvatarRole.new
    assert_not role.valid?
    assert_not role.errors[:key].empty?
    assert_not role.errors[:name].empty?
  end
end
