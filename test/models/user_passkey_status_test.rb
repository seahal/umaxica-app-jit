# frozen_string_literal: true

# == Schema Information
#
# Table name: user_passkey_statuses
# Database name: principal
#
#  id :integer          not null, primary key
#
require "test_helper"

class UserPasskeyStatusTest < ActiveSupport::TestCase
  fixtures :user_passkey_statuses

  test "valid status" do
    status = UserPasskeyStatus.new(id: 99)
    assert_predicate status, :valid?
    assert status.save
    assert_equal 99, status.id
  end

  test "status constants are defined" do
    assert_equal 0, UserPasskeyStatus::NEYO
    assert_equal 1, UserPasskeyStatus::ACTIVE
    assert_equal 2, UserPasskeyStatus::DISABLED
    assert_equal 3, UserPasskeyStatus::DELETED
  end

  test "validates id is non-negative" do
    record = UserPasskeyStatus.new(id: -1)
    assert_predicate record, :invalid?
    assert_includes record.errors[:id], "must be greater than or equal to 0"
  end

  test "validates id is an integer" do
    record = UserPasskeyStatus.new(id: 1.5)
    assert_predicate record, :invalid?
  end

  test "validates uniqueness of id" do
    UserPasskeyStatus.create!(id: 99)
    duplicate = UserPasskeyStatus.new(id: 99)
    assert_predicate duplicate, :invalid?
    assert_predicate duplicate.errors[:id], :any?
  end
end
