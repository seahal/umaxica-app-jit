# frozen_string_literal: true

# == Schema Information
#
# Table name: user_social_apple_statuses
# Database name: principal
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_user_social_apple_statuses_on_code  (code) UNIQUE
#
require "test_helper"

class UserSocialAppleStatusTest < ActiveSupport::TestCase
  test "valid status" do
    status = UserSocialAppleStatus.new(id: 99)
    assert_predicate status, :valid?
    assert status.save
    assert_equal 99, status.id
  end

  test "status constants are defined" do
    assert_equal 0, UserSocialAppleStatus::NEYO
    assert_equal 1, UserSocialAppleStatus::ACTIVE
    assert_equal 2, UserSocialAppleStatus::REVOKED
    assert_equal 3, UserSocialAppleStatus::DELETED
  end

  test "validates id is non-negative" do
    record = UserSocialAppleStatus.new(id: -1)
    assert_predicate record, :invalid?
    assert_includes record.errors[:id], "must be greater than or equal to 0"
  end

  test "validates id is an integer" do
    record = UserSocialAppleStatus.new(id: 1.5)
    assert_predicate record, :invalid?
  end

  test "validates uniqueness of id" do
    UserSocialAppleStatus.create!(id: 99)
    duplicate = UserSocialAppleStatus.new(id: 99)
    assert_predicate duplicate, :invalid?
    assert_predicate duplicate.errors[:id], :any?
  end
end
