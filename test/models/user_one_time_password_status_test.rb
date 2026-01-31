# frozen_string_literal: true

# == Schema Information
#
# Table name: user_one_time_password_statuses
# Database name: principal
#
#  id :integer          default(0), not null, primary key
#
# Indexes
#
#  index_user_one_time_password_statuses_on_id  (id) UNIQUE
#
require "test_helper"

class UserOneTimePasswordStatusTest < ActiveSupport::TestCase
  test "valid status" do
    status = UserOneTimePasswordStatus.new(id: 99)
    assert_predicate status, :valid?
    assert status.save
    assert_equal 99, status.id
  end

  test "status constants are defined" do
    assert_equal 0, UserOneTimePasswordStatus::NEYO
    assert_equal 1, UserOneTimePasswordStatus::ACTIVE
    assert_equal 2, UserOneTimePasswordStatus::INACTIVE
    assert_equal 3, UserOneTimePasswordStatus::REVOKED
    assert_equal 4, UserOneTimePasswordStatus::DELETED
  end

  test "validates id is non-negative" do
    record = UserOneTimePasswordStatus.new(id: -1)
    assert_predicate record, :invalid?
    assert_includes record.errors[:id], "must be greater than or equal to 0"
  end

  test "validates id is an integer" do
    record = UserOneTimePasswordStatus.new(id: 1.5)
    assert_predicate record, :invalid?
  end

  test "validates uniqueness of id" do
    UserOneTimePasswordStatus.create!(id: 99)
    duplicate = UserOneTimePasswordStatus.new(id: 99)
    assert_predicate duplicate, :invalid?
    assert_predicate duplicate.errors[:id], :any?
  end
end
