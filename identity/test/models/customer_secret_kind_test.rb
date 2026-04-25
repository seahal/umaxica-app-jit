# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: customer_secret_kinds
# Database name: guest
#
#  id :bigint           not null, primary key
#

require "test_helper"

class CustomerSecretKindTest < ActiveSupport::TestCase
  test "constants have expected values" do
    assert_equal 1, CustomerSecretKind::LOGIN
    assert_equal 2, CustomerSecretKind::TOTP
    assert_equal 3, CustomerSecretKind::RECOVERY
    assert_equal 4, CustomerSecretKind::API
  end

  test "PERMANENT aliases LOGIN" do
    assert_equal CustomerSecretKind::LOGIN, CustomerSecretKind::PERMANENT
  end

  test "ONE_TIME aliases RECOVERY" do
    assert_equal CustomerSecretKind::RECOVERY, CustomerSecretKind::ONE_TIME
  end

  test "ALLOWED_FOR_SECRET_SIGN_IN contains PERMANENT and ONE_TIME" do
    assert_includes CustomerSecretKind::ALLOWED_FOR_SECRET_SIGN_IN, CustomerSecretKind::PERMANENT
    assert_includes CustomerSecretKind::ALLOWED_FOR_SECRET_SIGN_IN, CustomerSecretKind::ONE_TIME
  end

  test "ALL contains all four base kinds" do
    assert_equal [1, 2, 3, 4].sort, CustomerSecretKind::ALL.sort
  end

  test "has_many customer_secrets association is defined" do
    association = CustomerSecretKind.reflect_on_association(:customer_secrets)

    assert_not_nil association
    assert_equal :has_many, association.macro
  end

  test "has_many customer_secrets has dependent restrict_with_exception" do
    association = CustomerSecretKind.reflect_on_association(:customer_secrets)

    assert_equal :restrict_with_exception, association.options[:dependent]
  end

  test "uses id as primary key" do
    assert_equal "id", CustomerSecretKind.primary_key.to_s
  end
end
