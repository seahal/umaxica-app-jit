# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: customer_token_kinds
# Database name: token
#
#  id :bigint           not null, primary key
#

require "test_helper"

class CustomerTokenKindTest < ActiveSupport::TestCase
  test "constants have expected values" do
    assert_equal 1, CustomerTokenKind::BROWSER_WEB
    assert_equal 2, CustomerTokenKind::CLIENT_IOS
    assert_equal 3, CustomerTokenKind::CLIENT_ANDROID
  end

  test "has_many customer_tokens association is defined" do
    association = CustomerTokenKind.reflect_on_association(:customer_tokens)

    assert_not_nil association
    assert_equal :has_many, association.macro
  end

  test "has_many customer_tokens has dependent restrict_with_error" do
    association = CustomerTokenKind.reflect_on_association(:customer_tokens)

    assert_equal :restrict_with_error, association.options[:dependent]
  end

  test "uses id as primary key" do
    assert_equal "id", CustomerTokenKind.primary_key.to_s
  end

  test "does not record timestamps" do
    assert_not CustomerTokenKind.record_timestamps
  end
end
