# == Schema Information
#
# Table name: avatar_assignments
#
#  id         :uuid             not null, primary key
#  avatar_id  :string(255)      not null
#  user_id    :uuid             not null
#  role       :string(50)       default("viewer"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_avatar_assignments_on_user_id          (user_id)
#  index_avatar_assignments_unique              (avatar_id,user_id,role) UNIQUE
#  index_avatar_assignments_unique_affiliation  (avatar_id) UNIQUE
#  index_avatar_assignments_unique_owner        (avatar_id) UNIQUE
#

# frozen_string_literal: true

require "test_helper"

class AvatarAssignmentTest < ActiveSupport::TestCase
  test "should have ROLES constant" do
    assert_equal %w(owner affiliation administrator editor reviewer viewer),
                 AvatarAssignment::ROLES
  end

  test "should validate role inclusion" do
    assignment = AvatarAssignment.new(role: "invalid_role")
    assert_not assignment.valid?
    assert_predicate assignment.errors[:role], :present?
  end

  test "should allow valid roles" do
    AvatarAssignment::ROLES.each do |role|
      assignment = AvatarAssignment.new(role: role)
      assignment.valid?
      # Role should not have "not included" error
      assert_not assignment.errors[:role].any? { |msg| msg.include?("一覧") || msg.include?("included") }
    end
  end
end
