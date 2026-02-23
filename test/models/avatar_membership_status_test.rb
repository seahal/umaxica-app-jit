# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: avatar_membership_statuses
# Database name: avatar
#
#  id :bigint           not null, primary key
#

require "test_helper"

class AvatarMembershipStatusTest < ActiveSupport::TestCase
  test "validations" do
    status = AvatarMembershipStatus.new(id: 9)
    assert_predicate status, :valid?
  end

  test "constants are defined" do
    assert_equal 1, AvatarMembershipStatus::NEYO
    assert_equal 2, AvatarMembershipStatus::ACTIVE
    assert_equal 3, AvatarMembershipStatus::INACTIVE
    assert_equal 4, AvatarMembershipStatus::DELETED
  end
end
