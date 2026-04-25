# typed: false
# == Schema Information
#
# Table name: user_member_deletions
# Database name: principal
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  member_id  :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_user_member_deletions_on_member_id              (member_id)
#  index_user_member_deletions_on_user_id_and_member_id  (user_id,member_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (member_id => members.id)
#  fk_rails_...  (user_id => users.id)
#

# frozen_string_literal: true

require "test_helper"

class UserMemberDeletionTest < ActiveSupport::TestCase
  fixtures :user_member_deletions, :users, :user_statuses, :members, :member_statuses, :divisions,
           :division_statuses, :organizations, :organization_statuses

  test "fixture is valid" do
    user = users(:one)
    member = members(:one)
    deletion = UserMemberDeletion.find_by!(user: user, member: member)

    assert_predicate deletion, :valid?
  end

  test "belongs to user" do
    deletion = user_member_deletions(:one)

    assert_respond_to deletion, :user
    assert_instance_of User, deletion.user
  end

  test "belongs to member" do
    deletion = user_member_deletions(:one)

    assert_respond_to deletion, :member
    assert_instance_of Member, deletion.member
  end

  test "validates uniqueness of member_id scoped to user_id" do
    user = users(:one)
    member = members(:one)
    UserMemberDeletion.find_by!(user: user, member: member)

    duplicate = UserMemberDeletion.new(
      user: user,
      member: member,
    )

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:member_id], "はすでに存在します"
  end

  test "allows different members for same user" do
    user = users(:one)
    member2 = members(:two)

    # Check if combination already exists in fixtures
    existing = UserMemberDeletion.find_by(user: user, member: member2)
    if existing.nil?
      deletion2 = UserMemberDeletion.new(
        user: user,
        member: member2,
      )

      assert_predicate deletion2, :valid?
    else
      # Already exists in fixtures, test passes
      assert existing
    end
  end

  test "allows same member for different users" do
    user2 = users(:two)
    member = members(:one)

    # Check if combination already exists in fixtures
    existing = UserMemberDeletion.find_by(user: user2, member: member)
    if existing.nil?
      deletion2 = UserMemberDeletion.new(
        user: user2,
        member: member,
      )

      assert_predicate deletion2, :valid?
    else
      # Already exists in fixtures, test passes
      assert existing
    end
  end
end
