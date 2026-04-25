# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: user_token_kinds
# Database name: token
#
#  id :bigint           not null, primary key
#

require "test_helper"

class UserTokenKindTest < ActiveSupport::TestCase
  test "constants have expected values" do
    assert_equal 11, UserTokenKind::BROWSER_WEB
    assert_equal 12, UserTokenKind::CLIENT_IOS
    assert_equal 13, UserTokenKind::CLIENT_ANDROID
  end

  test "has_many user_tokens association is defined" do
    association = UserTokenKind.reflect_on_association(:user_tokens)

    assert_not_nil association
    assert_equal :has_many, association.macro
  end

  test "has_many user_tokens has dependent restrict_with_error" do
    association = UserTokenKind.reflect_on_association(:user_tokens)

    assert_equal :restrict_with_error, association.options[:dependent]
  end

  test "uses id as primary key" do
    assert_equal "id", UserTokenKind.primary_key.to_s
  end

  test "does not record timestamps" do
    assert_not UserTokenKind.record_timestamps
  end
end
