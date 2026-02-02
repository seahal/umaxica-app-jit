# == Schema Information
#
# Table name: staff_secret_kinds
# Database name: operator
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_staff_secret_kinds_on_code  (code) UNIQUE
#

# frozen_string_literal: true

require "test_helper"

class StaffSecretKindTest < ActiveSupport::TestCase
  test "valid kind" do
    kind = StaffSecretKind.new(id: "TEST_KIND")
    assert_predicate kind, :valid?
    assert kind.save
    assert_equal "TEST_KIND", kind.id
  end

  test "upcases id" do
    kind = StaffSecretKind.new(id: "lower")
    kind.valid?
    assert_equal "LOWER", kind.id
  end

  test "validates length of id" do
    record = StaffSecretKind.new(id: "A" * 256)
    assert_predicate record, :invalid?
    assert_predicate record.errors[:id], :any?
  end

  test "validates uniqueness of id" do
    StaffSecretKind.create!(id: "UNIQUE_TEST")
    duplicate = StaffSecretKind.new(id: "UNIQUE_TEST")
    assert_predicate duplicate, :invalid?
    assert_predicate duplicate.errors[:id], :any?
  end

  test "validates format of id" do
    record = StaffSecretKind.new(id: "invalid-chars")
    assert_predicate record, :invalid?
    assert_predicate record.errors[:id], :any?
  end

  test "constants are defined" do
    assert_equal "LOGIN", StaffSecretKind::LOGIN
    assert_equal "TOTP", StaffSecretKind::TOTP
    assert_equal %w(LOGIN TOTP), StaffSecretKind::ALL
  end
end
