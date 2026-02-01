# frozen_string_literal: true

# == Schema Information
#
# Table name: avatar_membership_statuses
# Database name: avatar
#
#  id :integer          not null, primary key
#
# Indexes
#
#  index_avatar_membership_statuses_on_id  (id) UNIQUE
#

require "test_helper"

class AvatarMembershipStatusTest < ActiveSupport::TestCase
  test "validations" do
    status = AvatarMembershipStatus.new(id: "TEST_STATUS")
    assert_predicate status, :valid?
  end

  test "validates length of id" do
    record = AvatarMembershipStatus.new(id: "A" * 256)
    assert_predicate record, :invalid?
    assert_predicate record.errors[:id], :any?
  end
end
