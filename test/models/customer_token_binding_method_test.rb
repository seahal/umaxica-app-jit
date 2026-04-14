# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: customer_token_binding_methods
# Database name: token
#
#  id :bigint           not null, primary key
#

require "test_helper"

class CustomerTokenBindingMethodTest < ActiveSupport::TestCase
  test "constants have expected values" do
    assert_equal 0, CustomerTokenBindingMethod::NOTHING
    assert_equal 1, CustomerTokenBindingMethod::DBSC
    assert_equal 2, CustomerTokenBindingMethod::LEGACY
  end

  test "DEFAULTS contains NOTHING, DBSC, and LEGACY" do
    assert_includes CustomerTokenBindingMethod::DEFAULTS, CustomerTokenBindingMethod::NOTHING
    assert_includes CustomerTokenBindingMethod::DEFAULTS, CustomerTokenBindingMethod::DBSC
    assert_includes CustomerTokenBindingMethod::DEFAULTS, CustomerTokenBindingMethod::LEGACY
  end

  test "has_many customer_tokens association is defined" do
    association = CustomerTokenBindingMethod.reflect_on_association(:customer_tokens)

    assert_not_nil association
    assert_equal :has_many, association.macro
  end

  test "has_many customer_tokens has dependent restrict_with_error" do
    association = CustomerTokenBindingMethod.reflect_on_association(:customer_tokens)

    assert_equal :restrict_with_error, association.options[:dependent]
  end

  test "uses id as primary key" do
    assert_equal "id", CustomerTokenBindingMethod.primary_key.to_s
  end
end
