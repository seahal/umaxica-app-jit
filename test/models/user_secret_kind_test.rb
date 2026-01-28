# == Schema Information
#
# Table name: user_secret_kinds
# Database name: principal
#
#  id :string(255)      not null, primary key
#

# frozen_string_literal: true

require "test_helper"

class UserSecretKindTest < ActiveSupport::TestCase
  test "valid kind" do
    kind = UserSecretKind.new(id: "TEST_KIND")
    assert_predicate kind, :valid?
    assert kind.save
    assert_equal "TEST_KIND", kind.id
  end

  test "upcases id" do
    kind = UserSecretKind.new(id: "lower")
    kind.valid?
    assert_equal "LOWER", kind.id
  end

  test "validates length of id" do
    record = UserSecretKind.new(id: "A" * 256)
    assert_predicate record, :invalid?
    assert_predicate record.errors[:id], :any?
  end

  test "validates uniqueness of id" do
    UserSecretKind.create!(id: "UNIQUE_TEST")
    duplicate = UserSecretKind.new(id: "UNIQUE_TEST")
    assert_predicate duplicate, :invalid?
    assert_predicate duplicate.errors[:id], :any?
  end

  test "validates format of id" do
    record = UserSecretKind.new(id: "invalid-chars")
    assert_predicate record, :invalid?
    assert_predicate record.errors[:id], :any?
  end

  test "constants are defined" do
    assert_equal "UNLIMITED", UserSecretKind::UNLIMITED
    assert_equal "ONE_TIME", UserSecretKind::ONE_TIME
    assert_equal "TIME_BOUND", UserSecretKind::TIME_BOUND
    assert_equal %w[UNLIMITED ONE_TIME TIME_BOUND], UserSecretKind::ALL
  end

  # Constitution test: Ensures the canonical set of kinds is enforced
  # This test will fail if anyone adds/removes kinds from the database
  test "kind constitution: only canonical lifetime kinds exist in database" do
    canonical_kinds = %w[UNLIMITED ONE_TIME TIME_BOUND]
    actual_kinds = UserSecretKind.pluck(:id).sort

    assert_equal canonical_kinds.sort, actual_kinds,
                 "Database must contain exactly the canonical lifetime kinds: #{canonical_kinds.join(', ')}"
  end

  # Constitution test: Ensures all kinds follow UPPER_SNAKE_CASE naming
  test "kind constitution: all kinds follow UPPER_SNAKE_CASE format" do
    UserSecretKind.find_each do |kind|
      assert_match(/\A[A-Z0-9_]+\z/, kind.id,
                   "Kind ID '#{kind.id}' must be UPPER_SNAKE_CASE")
    end
  end
end
