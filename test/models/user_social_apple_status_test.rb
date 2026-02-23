# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: user_social_apple_statuses
# Database name: principal
#
#  id :bigint           not null, primary key
#
require "test_helper"

class UserSocialAppleStatusTest < ActiveSupport::TestCase
  test "status constants are defined" do
    assert_equal 1, UserSocialAppleStatus::ACTIVE
    assert_equal 2, UserSocialAppleStatus::INACTIVE
    assert_equal 3, UserSocialAppleStatus::PENDING
    assert_equal 4, UserSocialAppleStatus::DELETED
    assert_equal 5, UserSocialAppleStatus::REVOKED
    assert_equal 6, UserSocialAppleStatus::NEYO
  end

  test "status ids are integers" do
    assert_kind_of Integer, UserSocialAppleStatus::ACTIVE
    assert_kind_of Integer, UserSocialAppleStatus::INACTIVE
    assert_kind_of Integer, UserSocialAppleStatus::PENDING
    assert_kind_of Integer, UserSocialAppleStatus::DELETED
    assert_kind_of Integer, UserSocialAppleStatus::REVOKED
    assert_kind_of Integer, UserSocialAppleStatus::NEYO
  end
end
