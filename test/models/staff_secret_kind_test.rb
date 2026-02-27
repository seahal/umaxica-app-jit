# typed: false
# == Schema Information
#
# Table name: staff_secret_kinds
# Database name: operator
#
#  id :bigint           not null, primary key
#

# frozen_string_literal: true

require "test_helper"

class StaffSecretKindTest < ActiveSupport::TestCase
  test "valid kind" do
    kind = StaffSecretKind.new(id: 99)

    assert_predicate kind, :valid?
    assert kind.save
    assert_equal 99, kind.id
  end

  test "validates uniqueness of id" do
    StaffSecretKind.create!(id: 77)
    duplicate = StaffSecretKind.new(id: 77)

    assert_predicate duplicate, :invalid?
    assert_predicate duplicate.errors[:id], :any?
  end

  test "constants are defined" do
    assert_equal 2, StaffSecretKind::LOGIN
    assert_equal 3, StaffSecretKind::TOTP
    assert_equal [2, 3], StaffSecretKind::ALL
  end
end
