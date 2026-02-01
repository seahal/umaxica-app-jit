# frozen_string_literal: true

# == Schema Information
#
# Table name: avatar_ownership_statuses
# Database name: avatar
#
#  id :integer          not null, primary key
#
# Indexes
#
#  index_avatar_ownership_statuses_on_id  (id) UNIQUE
#

require "test_helper"

class AvatarOwnershipStatusTest < ActiveSupport::TestCase
  test "validations" do
    status = AvatarOwnershipStatus.new(id: "TEST_STATUS")
    assert_predicate status, :valid?
  end

  test "validates length of id" do
    record = AvatarOwnershipStatus.new(id: "A" * 256)
    assert_predicate record, :invalid?
    assert_predicate record.errors[:id], :any?
  end
end
