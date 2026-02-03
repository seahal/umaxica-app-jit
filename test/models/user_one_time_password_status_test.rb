# frozen_string_literal: true

# == Schema Information
#
# Table name: user_one_time_password_statuses
# Database name: principal
#
#  id :bigint           not null, primary key
#
require "test_helper"

class UserOneTimePasswordStatusTest < ActiveSupport::TestCase
  test "status constants are defined" do
    assert_equal 1, UserOneTimePasswordStatus::ACTIVE
    assert_equal 2, UserOneTimePasswordStatus::INACTIVE
    assert_equal 3, UserOneTimePasswordStatus::REVOKED
    assert_equal 4, UserOneTimePasswordStatus::DELETED
    assert_equal 5, UserOneTimePasswordStatus::NEYO
  end

  test "status ids are integers" do
    assert_kind_of Integer, UserOneTimePasswordStatus::ACTIVE
    assert_kind_of Integer, UserOneTimePasswordStatus::INACTIVE
    assert_kind_of Integer, UserOneTimePasswordStatus::REVOKED
    assert_kind_of Integer, UserOneTimePasswordStatus::DELETED
    assert_kind_of Integer, UserOneTimePasswordStatus::NEYO
  end
end
