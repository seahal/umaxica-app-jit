# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: app_preference_activity_levels
# Database name: activity
#
#  id :bigint           not null, primary key
#
require "test_helper"

class AppPreferenceActivityLevelTest < ActiveSupport::TestCase
  fixtures :app_preference_activity_levels

  test "ordered scope sorts by id when position is absent" do
    ordered_ids = AppPreferenceActivityLevel.ordered.pluck(:id)

    assert_equal ordered_ids.sort, ordered_ids
  end

  test "INFO constant is defined" do
    assert_equal 1, AppPreferenceActivityLevel::INFO
  end

  test "record_timestamps is disabled" do
    assert_not AppPreferenceActivityLevel.record_timestamps
  end

  test "has_many association with app_preference_activities" do
    association = AppPreferenceActivityLevel.reflect_on_association(:app_preference_activities)

    assert_equal :has_many, association.macro
    assert_equal :restrict_with_error, association.options[:dependent]
  end

  test "DEFAULTS includes INFO" do
    assert_includes AppPreferenceActivityLevel::DEFAULTS, AppPreferenceActivityLevel::INFO
  end

  test "ensure_defaults! creates the INFO record" do
    AppPreferenceActivity.delete_all
    AppPreferenceActivityLevel.where(id: AppPreferenceActivityLevel::INFO).delete_all

    assert_nil AppPreferenceActivityLevel.find_by(id: AppPreferenceActivityLevel::INFO)

    AppPreferenceActivityLevel.ensure_defaults!

    assert_not_nil AppPreferenceActivityLevel.find_by(id: AppPreferenceActivityLevel::INFO)
  end

  test "ensure_defaults! is idempotent" do
    AppPreferenceActivityLevel.ensure_defaults!
    assert_nothing_raised { AppPreferenceActivityLevel.ensure_defaults! }
  end
end
