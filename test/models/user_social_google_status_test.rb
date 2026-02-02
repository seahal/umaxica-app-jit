# frozen_string_literal: true

# == Schema Information
#
# Table name: user_social_google_statuses
# Database name: principal
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_user_social_google_statuses_on_code  (code) UNIQUE
#
require "test_helper"

class UserSocialGoogleStatusTest < ActiveSupport::TestCase
  test "valid status" do
    status = UserSocialGoogleStatus.new(id: 99)
    assert_predicate status, :valid?
    assert status.save
    assert_equal 99, status.id
  end

  test "status constants are defined" do
    assert_equal 0, UserSocialGoogleStatus::NEYO
    assert_equal 1, UserSocialGoogleStatus::ACTIVE
    assert_equal 2, UserSocialGoogleStatus::REVOKED
    assert_equal 3, UserSocialGoogleStatus::DELETED
  end

  test "validates id is non-negative" do
    record = UserSocialGoogleStatus.new(id: -1)
    assert_predicate record, :invalid?
    assert_includes record.errors[:id], "must be greater than or equal to 0"
  end

  test "validates id is an integer" do
    record = UserSocialGoogleStatus.new(id: 1.5)
    assert_predicate record, :invalid?
  end

  test "validates uniqueness of id" do
    UserSocialGoogleStatus.create!(id: 99)
    duplicate = UserSocialGoogleStatus.new(id: 99)
    assert_predicate duplicate, :invalid?
    assert_predicate duplicate.errors[:id], :any?
  end
end
