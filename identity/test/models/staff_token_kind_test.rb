# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_token_kinds
# Database name: token
#
#  id :bigint           not null, primary key
#

require "test_helper"

class StaffTokenKindTest < ActiveSupport::TestCase
  test "constants have expected values" do
    assert_equal 1, StaffTokenKind::BROWSER_WEB
    assert_equal 2, StaffTokenKind::CLIENT_IOS
    assert_equal 3, StaffTokenKind::CLIENT_ANDROID
  end

  test "has_many staff_tokens association is defined" do
    association = StaffTokenKind.reflect_on_association(:staff_tokens)

    assert_not_nil association
    assert_equal :has_many, association.macro
  end

  test "has_many staff_tokens has dependent restrict_with_error" do
    association = StaffTokenKind.reflect_on_association(:staff_tokens)

    assert_equal :restrict_with_error, association.options[:dependent]
  end

  test "uses id as primary key" do
    assert_equal "id", StaffTokenKind.primary_key.to_s
  end

  test "does not record timestamps" do
    assert_not StaffTokenKind.record_timestamps
  end
end
