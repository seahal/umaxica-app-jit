# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: user_members
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
#  index_user_members_on_member_id              (member_id)
#  index_user_members_on_user_id_and_member_id  (user_id,member_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (member_id => members.id) ON DELETE => cascade
#  fk_rails_...  (user_id => users.id) ON DELETE => cascade
#

require "test_helper"

class UserMemberTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(public_id: "u_#{SecureRandom.hex(8)}", status_id: UserStatus::NOTHING)
    @member = members(:one)
  end

  test "should be valid with user and member" do
    user_member = UserMember.new(
      user: @user,
      member: @member,
    )

    assert_predicate user_member, :valid?
  end

  test "should require user" do
    user_member = UserMember.new(
      member: @member,
    )

    assert_not user_member.valid?
    assert_not_empty user_member.errors[:user]
  end

  test "should require member" do
    user_member = UserMember.new(
      user: @user,
    )

    assert_not user_member.valid?
    assert_not_empty user_member.errors[:member]
  end

  test "member_id must be unique scoped to user_id" do
    UserMember.create!(
      user: @user,
      member: @member,
    )

    duplicate = UserMember.new(
      user: @user,
      member: @member,
    )

    assert_not duplicate.valid?
    assert_not_empty duplicate.errors[:member_id]
  end

  test "same member with different user is allowed" do
    UserMember.create!(
      user: @user,
      member: @member,
    )

    other_user = User.create!(public_id: "u_#{SecureRandom.hex(8)}", status_id: UserStatus::NOTHING)
    different_user_member = UserMember.new(
      user: other_user,
      member: @member,
    )

    assert_predicate different_user_member, :valid?
  end

  test "same user with different members is allowed" do
    UserMember.create!(
      user: @user,
      member: @member,
    )

    other_member = members(:two)
    different_member = UserMember.new(
      user: @user,
      member: other_member,
    )

    assert_predicate different_member, :valid?
  end

  test "belongs to user" do
    user_member = UserMember.create!(
      user: @user,
      member: @member,
    )

    assert_equal @user, user_member.user
  end

  test "belongs to member" do
    user_member = UserMember.create!(
      user: @user,
      member: @member,
    )

    assert_equal @member, user_member.member
  end

  test "association: user has many members through user_members" do
    UserMember.create!(
      user: @user,
      member: @member,
    )

    assert_includes @user.members, @member
  end

  test "association: member has many users through user_members" do
    UserMember.create!(
      user: @user,
      member: @member,
    )

    assert_includes @member.users, @user
  end
end
