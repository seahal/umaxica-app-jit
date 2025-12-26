require "test_helper"

class AvatarMembershipTest < ActiveSupport::TestCase
  test "validations" do
    membership = AvatarMembership.new
    assert_not membership.valid?
    assert_not membership.errors[:actor_id].empty?
    assert_not membership.errors[:role_id].empty?
    # valid_from is required but might be auto-set by DB default? No, schema says not null, model validation says presence.
    # But usually creating empty object checks presence.
  end
end
