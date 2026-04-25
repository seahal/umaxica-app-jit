# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_secret_statuses
# Database name: operator
#
#  id :bigint           not null, primary key
#

require "test_helper"

class StaffSecretStatusTest < ActiveSupport::TestCase
  test "constants have expected values" do
    assert_equal 1, StaffSecretStatus::ACTIVE
    assert_equal 2, StaffSecretStatus::DELETED
    assert_equal 3, StaffSecretStatus::EXPIRED
    assert_equal 4, StaffSecretStatus::REVOKED
    assert_equal 5, StaffSecretStatus::USED
  end

  test "has_many staff_secrets association is defined" do
    association = StaffSecretStatus.reflect_on_association(:staff_secrets)

    assert_not_nil association
    assert_equal :has_many, association.macro
  end

  test "has_many staff_secrets has dependent restrict_with_error" do
    association = StaffSecretStatus.reflect_on_association(:staff_secrets)

    assert_equal :restrict_with_error, association.options[:dependent]
  end

  test "uses id as primary key" do
    assert_equal "id", StaffSecretStatus.primary_key.to_s
  end
end
