# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: app_preference_statuses
# Database name: preference
#
#  id :bigint           not null, primary key
#
require "test_helper"

class AppPreferenceStatusTest < ActiveSupport::TestCase
  test "has correct constants" do
    assert_equal 1, AppPreferenceStatus::DELETED
    assert_equal 2, AppPreferenceStatus::NOTHING
  end

  test "defaults includes DELETED and NOTHING" do
    assert_includes AppPreferenceStatus::DEFAULTS, AppPreferenceStatus::DELETED
    assert_includes AppPreferenceStatus::DEFAULTS, AppPreferenceStatus::NOTHING
  end
end
