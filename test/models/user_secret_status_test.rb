# frozen_string_literal: true

# == Schema Information
#
# Table name: user_secret_statuses
# Database name: principal
#
#  id :bigint           not null, primary key
#
require "test_helper"

class UserSecretStatusTest < ActiveSupport::TestCase
  test "status constants are defined" do
    assert_equal 1, UserSecretStatus::ACTIVE
    assert_equal 2, UserSecretStatus::EXPIRED
    assert_equal 3, UserSecretStatus::REVOKED
    assert_equal 4, UserSecretStatus::USED
    assert_equal 5, UserSecretStatus::DELETED
    assert_equal 6, UserSecretStatus::NEYO
  end

  test "status ids are integers" do
    assert_kind_of Integer, UserSecretStatus::ACTIVE
    assert_kind_of Integer, UserSecretStatus::EXPIRED
    assert_kind_of Integer, UserSecretStatus::REVOKED
    assert_kind_of Integer, UserSecretStatus::USED
    assert_kind_of Integer, UserSecretStatus::DELETED
    assert_kind_of Integer, UserSecretStatus::NEYO
  end
end
