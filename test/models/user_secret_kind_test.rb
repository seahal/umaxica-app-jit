# == Schema Information
#
# Table name: user_secret_kinds
# Database name: principal
#
#  id :integer          not null, primary key
#
#

# frozen_string_literal: true

require "test_helper"

class UserSecretKindTest < ActiveSupport::TestCase
  test "valid kind" do
    kind = UserSecretKind.new(id: 99)
    assert_predicate kind, :valid?
    assert kind.save
    assert_equal 99, kind.id
  end

  test "validates uniqueness of id" do
    UserSecretKind.create!(id: 99)
    duplicate = UserSecretKind.new(id: 99)
    assert_predicate duplicate, :invalid?
    assert_predicate duplicate.errors[:id], :any?
  end

  test "constants are defined" do
    assert_equal 1, UserSecretKind::LOGIN
    assert_equal 2, UserSecretKind::TOTP
    assert_equal 3, UserSecretKind::RECOVERY
    assert_equal 4, UserSecretKind::API
    assert_equal [1, 2, 3, 4], UserSecretKind::ALL
  end

  test "validates id is non-negative" do
    record = UserSecretKind.new(id: -1)
    assert_predicate record, :invalid?
    assert_includes record.errors[:id], "must be greater than or equal to 0"
  end

  test "validates id is an integer" do
    record = UserSecretKind.new(id: 1.5)
    assert_predicate record, :invalid?
  end
end
