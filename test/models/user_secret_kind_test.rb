# == Schema Information
#
# Table name: user_secret_kinds
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
    assert_equal "LOGIN", UserSecretKind::LOGIN
    assert_equal "TOTP", UserSecretKind::TOTP
    assert_equal "RECOVERY", UserSecretKind::RECOVERY
    assert_equal "API", UserSecretKind::API
    assert_equal %w(LOGIN TOTP RECOVERY API), UserSecretKind::ALL
  end
end
