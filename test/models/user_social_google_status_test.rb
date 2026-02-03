# frozen_string_literal: true

# == Schema Information
#
# Table name: user_social_google_statuses
# Database name: principal
#
#  id :bigint           not null, primary key
#
require "test_helper"

class UserSocialGoogleStatusTest < ActiveSupport::TestCase
  test "status constants are defined" do
    assert_equal 1, UserSocialGoogleStatus::ACTIVE
    assert_equal 2, UserSocialGoogleStatus::INACTIVE
    assert_equal 3, UserSocialGoogleStatus::PENDING
    assert_equal 4, UserSocialGoogleStatus::DELETED
    assert_equal 5, UserSocialGoogleStatus::REVOKED
    assert_equal 6, UserSocialGoogleStatus::NEYO
  end

  test "status ids are integers" do
    assert_kind_of Integer, UserSocialGoogleStatus::ACTIVE
    assert_kind_of Integer, UserSocialGoogleStatus::INACTIVE
    assert_kind_of Integer, UserSocialGoogleStatus::PENDING
    assert_kind_of Integer, UserSocialGoogleStatus::DELETED
    assert_kind_of Integer, UserSocialGoogleStatus::REVOKED
    assert_kind_of Integer, UserSocialGoogleStatus::NEYO
  end
end
