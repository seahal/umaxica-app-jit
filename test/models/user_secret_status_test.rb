# frozen_string_literal: true

# == Schema Information
#
# Table name: user_secret_statuses
# Database name: principal
#
#  id :integer          not null, primary key
#
require "test_helper"

class UserSecretStatusTest < ActiveSupport::TestCase
  test "valid status" do
    status = UserSecretStatus.new(id: 99)
    assert_predicate status, :valid?
    assert status.save
    assert_equal 99, status.id
  end

  test "status constants are defined" do
    assert_equal 0, UserSecretStatus::NEYO
    assert_equal 1, UserSecretStatus::ACTIVE
    assert_equal 2, UserSecretStatus::USED
    assert_equal 3, UserSecretStatus::EXPIRED
    assert_equal 4, UserSecretStatus::REVOKED
    assert_equal 5, UserSecretStatus::DELETED
  end

  test "validates id is non-negative" do
    record = UserSecretStatus.new(id: -1)
    assert_predicate record, :invalid?
    assert_includes record.errors[:id], "must be greater than or equal to 0"
  end

  test "validates id is an integer" do
    record = UserSecretStatus.new(id: 1.5)
    assert_predicate record, :invalid?
  end

  test "validates uniqueness of id" do
    UserSecretStatus.create!(id: 99)
    duplicate = UserSecretStatus.new(id: 99)
    assert_predicate duplicate, :invalid?
    assert_predicate duplicate.errors[:id], :any?
  end
end
