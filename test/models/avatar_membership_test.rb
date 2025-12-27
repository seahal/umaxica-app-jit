# frozen_string_literal: true

# == Schema Information
#
# Table name: avatar_memberships
#
#  id                          :string           not null, primary key
#  avatar_id                   :string           not null
#  actor_id                    :string           not null
#  role_id                     :string           not null
#  valid_from                  :timestamptz      not null
#  valid_to                    :timestamptz      default("infinity"), not null
#  avatar_membership_status_id :string
#  granted_by_actor_id         :string
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#
# Indexes
#
#  index_avatar_memberships_on_actor_id                     (actor_id)
#  index_avatar_memberships_on_avatar_id_and_actor_id       (avatar_id,actor_id) UNIQUE
#  index_avatar_memberships_on_avatar_membership_status_id  (avatar_membership_status_id)
#

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
