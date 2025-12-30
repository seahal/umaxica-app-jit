# frozen_string_literal: true

# == Schema Information
#
# Table name: avatar_membership_statuses
#
#  id         :string           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require "test_helper"

class AvatarMembershipStatusTest < ActiveSupport::TestCase
  test "validations" do
    status = AvatarMembershipStatus.new
    assert_predicate status, :valid?
  end
end
