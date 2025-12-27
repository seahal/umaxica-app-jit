# frozen_string_literal: true

# == Schema Information
#
# Table name: avatar_ownership_periods
#
#  id                         :string           not null, primary key
#  avatar_id                  :string           not null
#  owner_organization_id      :string           not null
#  valid_from                 :timestamptz      not null
#  valid_to                   :timestamptz      default("infinity"), not null
#  avatar_ownership_status_id :string
#  transferred_by_actor_id    :string
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#
# Indexes
#
#  index_avatar_ownership_periods_on_avatar_id                   (avatar_id) UNIQUE
#  index_avatar_ownership_periods_on_avatar_ownership_status_id  (avatar_ownership_status_id)
#  index_avatar_ownership_periods_on_owner_organization_id       (owner_organization_id)
#

require "test_helper"

class AvatarOwnershipPeriodTest < ActiveSupport::TestCase
  test "validations" do
    period = AvatarOwnershipPeriod.new
    assert_not period.valid?
  end
end
