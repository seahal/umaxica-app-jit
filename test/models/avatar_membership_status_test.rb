# frozen_string_literal: true

# == Schema Information
#
# Table name: avatar_membership_statuses
#
#  id         :string           not null, primary key
#  key        :string           not null
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_avatar_membership_statuses_on_key  (key) UNIQUE
#

require "test_helper"

class AvatarMembershipStatusTest < ActiveSupport::TestCase
  test "validations" do
    status = AvatarMembershipStatus.new
    assert_not status.valid?
    assert_not status.errors[:key].empty?
  end
end
