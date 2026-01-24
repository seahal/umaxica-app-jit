# frozen_string_literal: true

# == Schema Information
#
# Table name: avatar_ownership_periods
# Database name: avatar
#
#  id                         :string           not null, primary key
#  valid_from                 :timestamptz      not null
#  valid_to                   :timestamptz      default(Infinity), not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  avatar_id                  :string           not null
#  avatar_ownership_status_id :string
#  owner_organization_id      :string           not null
#  transferred_by_actor_id    :string
#
# Indexes
#
#  index_avatar_ownership_periods_on_avatar_id                   (avatar_id) UNIQUE WHERE (valid_to = 'infinity'::timestamp with time zone)
#  index_avatar_ownership_periods_on_avatar_ownership_status_id  (avatar_ownership_status_id)
#  index_avatar_ownership_periods_on_owner_organization_id       (owner_organization_id) WHERE (valid_to = 'infinity'::timestamp with time zone)
#
# Foreign Keys
#
#  fk_rails_...  (avatar_id => avatars.id)
#  fk_rails_...  (avatar_ownership_status_id => avatar_ownership_statuses.id)
#

require "test_helper"

class AvatarOwnershipPeriodTest < ActiveSupport::TestCase
  test "validations" do
    period = AvatarOwnershipPeriod.new
    assert_not period.valid?
  end

  test "validates length of id" do
    record = AvatarOwnershipPeriod.new(id: "A" * 256)
    assert_predicate record, :invalid?
    assert_predicate record.errors[:id], :any?
  end
end
